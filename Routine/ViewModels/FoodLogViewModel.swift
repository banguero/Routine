// FoodLogViewModel.swift

import Foundation
import Combine
import UIKit

@MainActor
class FoodLogViewModel: ObservableObject {
    @Published var foodEntries: [FoodEntry] = []
    @Published var dailySummary: DailySummary?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let firestoreService = FirestoreService()
    private let storageService = StorageService()
    private let recognitionService = FoodRecognitionService()
    private var cancellables = Set<AnyCancellable>()
    
    private var userId: String
    private var user: User
    
    init(userId: String, user: User) {
        self.userId = userId
        self.user = user
        subscribeToFoodEntries()
    }
    
    func updateUser(userId: String, user: User) {
        self.userId = userId
        self.user = user
        // Resubscribe with new user
        cancellables.removeAll()
        subscribeToFoodEntries()
    }
    
    func subscribeToFoodEntries(date: Date = Date()) {
        firestoreService.getFoodEntries(userId: userId, date: date)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    self.errorMessage = error.localizedDescription
                    // Load mock data on error (e.g., for test user)
                    self.loadMockData()
                }
            }, receiveValue: { entries in
                if !entries.isEmpty {
                    self.foodEntries = entries
                } else {
                    // Load mock data if no entries found (e.g., for test user)
                    self.loadMockData()
                }
                self.updateDailySummary()
            })
            .store(in: &cancellables)
    }
    
    func addFoodEntry(name: String, calories: Double, protein: Double,
                      carbs: Double, fat: Double, mealType: MealType,
                      image: UIImage? = nil) async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            var imageUrl: String?
            if let image = image {
                imageUrl = try await storageService.uploadFoodImage(image, userId: userId)
            }
            
            let entry = FoodEntry(
                userId: userId,
                name: name,
                calories: calories,
                protein: protein,
                carbs: carbs,
                fat: fat,
                mealType: mealType,
                date: Date(),
                imageUrl: imageUrl,
                aiRecognized: false
            )
            
            // Add to local array immediately for UI responsiveness
            foodEntries.insert(entry, at: 0)
            updateDailySummary()
            
            // Save to Firestore
            try await firestoreService.addFoodEntry(entry)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func addFoodWithAI(image: UIImage, mealType: MealType = .lunch) async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            // Step 1: Recognize meal using AI (returns ingredients)
            print("🤖 Analyzing food photo with AI...")
            let recognizedMeal = try await recognitionService.recognizeMeal(from: image)
            print("✅ AI Analysis complete: \(recognizedMeal.name)")
            print("   Confidence: \(Int(recognizedMeal.confidence * 100))%")
            print("   Ingredients: \(recognizedMeal.ingredients.count)")
            print("   Total Calories: \(Int(recognizedMeal.totalCalories))")
            
            // Step 2: Upload image to Firebase Storage
            print("📤 Uploading image to Firebase Storage...")
            let imageUrl = try await storageService.uploadFoodImage(image, userId: userId)
            print("✅ Image uploaded: \(imageUrl)")
            
            // Step 3: Create entry with ingredients
            var entry = FoodEntry(
                userId: userId,
                name: recognizedMeal.name,
                calories: recognizedMeal.totalCalories,
                protein: recognizedMeal.totalProtein,
                carbs: recognizedMeal.totalCarbs,
                fat: recognizedMeal.totalFat,
                mealType: mealType,
                date: Date(),
                imageUrl: imageUrl,
                aiRecognized: true,
                confidence: recognizedMeal.confidence,
                ingredients: recognizedMeal.ingredients
            )
            
            // Calculate additional nutrients from ingredients
            entry.updateMacrosFromIngredients()
            
            // Add to local array immediately for UI responsiveness
            foodEntries.insert(entry, at: 0)
            updateDailySummary()
            
            // Step 4: Save to Firestore
            print("💾 Saving to Firestore...")
            try await firestoreService.addFoodEntry(entry)
            print("✅ Food entry saved successfully!")
            
        } catch {
            print("❌ Error adding food with AI: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
        }
    }
    
    func addMealWithIngredients(name: String, ingredients: [Ingredient], 
                                mealType: MealType, image: UIImage? = nil) async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            var imageUrl: String?
            if let image = image {
                imageUrl = try await storageService.uploadFoodImage(image, userId: userId)
            }
            
            // Calculate totals from ingredients
            let totalCalories = ingredients.reduce(0) { $0 + $1.calories }
            let totalProtein = ingredients.reduce(0) { $0 + $1.protein }
            let totalCarbs = ingredients.reduce(0) { $0 + $1.carbs }
            let totalFat = ingredients.reduce(0) { $0 + $1.fat }
            let totalSugar = ingredients.reduce(0) { $0 + $1.sugar }
            let totalFiber = ingredients.reduce(0) { $0 + $1.fiber }
            let totalSodium = ingredients.reduce(0) { $0 + $1.sodium }
            
            let entry = FoodEntry(
                userId: userId,
                name: name,
                calories: totalCalories,
                protein: totalProtein,
                carbs: totalCarbs,
                fat: totalFat,
                mealType: mealType,
                date: Date(),
                imageUrl: imageUrl,
                aiRecognized: false,
                ingredients: ingredients,
                sugar: totalSugar,
                fiber: totalFiber,
                sodium: totalSodium
            )
            
            // Add to local array immediately
            foodEntries.insert(entry, at: 0)
            updateDailySummary()
            
            // Save to Firestore
            try await firestoreService.addFoodEntry(entry)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func updateFoodEntry(_ entry: FoodEntry) async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            // Update local array
            if let index = foodEntries.firstIndex(where: { $0.id == entry.id }) {
                foodEntries[index] = entry
                updateDailySummary()
            }
            
            // Save to Firestore
            try await firestoreService.addFoodEntry(entry)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func deleteFoodEntry(id: String) async {
        // Remove from local array immediately
        foodEntries.removeAll { $0.id == id }
        updateDailySummary()
        
        // Delete from Firestore
        do {
            try await firestoreService.deleteFoodEntry(id: id)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    private func updateDailySummary() {
        let totalCalories = foodEntries.reduce(0) { $0 + $1.calories }
        let totalProtein = foodEntries.reduce(0) { $0 + $1.protein }
        let totalCarbs = foodEntries.reduce(0) { $0 + $1.carbs }
        let totalFat = foodEntries.reduce(0) { $0 + $1.fat }
        
        dailySummary = DailySummary(
            userId: userId,
            date: Date(),
            totalCalories: totalCalories,
            totalProtein: totalProtein,
            totalCarbs: totalCarbs,
            totalFat: totalFat,
            totalWaterOz: 0,
            calorieGoal: user.dailyCalorieGoal,
            proteinGoal: user.dailyProteinGoal,
            carbsGoal: user.dailyCarbsGoal,
            fatGoal: user.dailyFatGoal,
            waterGoalOz: user.dailyWaterGoalOz
        )
    }
    
    private func loadMockData() {
        // Mock data for development and preview
        // This will be replaced by real Firestore data
        if foodEntries.isEmpty {
            foodEntries = [
                FoodEntry(
                    id: "1",
                    userId: userId,
                    name: "Grilled Lamb & Chicken",
                    calories: 525,
                    protein: 55,
                    carbs: 0,
                    fat: 33,
                    mealType: .lunch,
                    date: Date(),
                    aiRecognized: true,
                    confidence: 0.88,
                    createdAt: Date(),
                    ingredients: [
                        Ingredient.sampleLamb(),
                        Ingredient.sampleChicken(),
                        Ingredient.sampleOliveOil(),
                        Ingredient.sampleSalt()
                    ],
                    sugar: 0,
                    fiber: 0,
                    sodium: 725
                ),
                FoodEntry(
                    id: "2",
                    userId: userId,
                    name: "Greek Yogurt with Berries",
                    calories: 180,
                    protein: 15,
                    carbs: 22,
                    fat: 4,
                    mealType: .breakfast,
                    date: Date().addingTimeInterval(-3600),
                    aiRecognized: true,
                    confidence: 0.92,
                    createdAt: Date().addingTimeInterval(-3600),
                    ingredients: [
                        Ingredient(
                            id: "5",
                            name: "Greek yogurt (1 cup)",
                            quantity: 1.0,
                            measurementType: .servings,
                            calories: 130,
                            protein: 12,
                            carbs: 9,
                            fat: 4,
                            sugar: 6,
                            fiber: 0,
                            sodium: 65
                        ),
                        Ingredient(
                            id: "6",
                            name: "Mixed berries (0.5 cup)",
                            quantity: 1.0,
                            measurementType: .servings,
                            calories: 50,
                            protein: 3,
                            carbs: 13,
                            fat: 0,
                            sugar: 8,
                            fiber: 3,
                            sodium: 2
                        )
                    ],
                    sugar: 14,
                    fiber: 3,
                    sodium: 67
                )
            ]
            updateDailySummary()
        }
    }
}
