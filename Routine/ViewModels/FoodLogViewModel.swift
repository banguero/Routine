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
                }
            }, receiveValue: { entries in
                if !entries.isEmpty {
                    self.foodEntries = entries
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
            // Recognize food using AI
            let recognized = try await recognitionService.recognizeFood(from: image)
            
            // Upload image
            let imageUrl = try await storageService.uploadFoodImage(image, userId: userId)
            
            // Create entry
            let entry = FoodEntry(
                userId: userId,
                name: recognized.name,
                calories: recognized.calories,
                protein: recognized.protein,
                carbs: recognized.carbs,
                fat: recognized.fat,
                mealType: mealType,
                date: Date(),
                imageUrl: imageUrl,
                aiRecognized: true,
                confidence: recognized.confidence
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
                    name: "Grilled Chicken Salad",
                    calories: 350,
                    protein: 35,
                    carbs: 15,
                    fat: 18,
                    mealType: .lunch,
                    date: Date(),
                    aiRecognized: true,
                    confidence: 0.85,
                    createdAt: Date()
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
                    createdAt: Date().addingTimeInterval(-3600)
                )
            ]
            updateDailySummary()
        }
    }
}
