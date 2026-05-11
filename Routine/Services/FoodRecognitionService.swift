// FoodRecognitionService.swift

import Foundation
import UIKit

struct RecognizedFood {
    let name: String
    let calories: Double
    let protein: Double
    let carbs: Double
    let fat: Double
    let confidence: Double
}

struct RecognizedMeal {
    let name: String
    let ingredients: [Ingredient]
    let confidence: Double
    let analysis: String? // AI-generated analysis of the meal
    
    var totalCalories: Double {
        ingredients.reduce(0) { $0 + $1.calories }
    }
    
    var totalProtein: Double {
        ingredients.reduce(0) { $0 + $1.protein }
    }
    
    var totalCarbs: Double {
        ingredients.reduce(0) { $0 + $1.carbs }
    }
    
    var totalFat: Double {
        ingredients.reduce(0) { $0 + $1.fat }
    }
}

class FoodRecognitionService {
    // TODO: Integrate with actual food recognition API
    // Options:
    // 1. Firebase ML Kit (on-device)
    // 2. Google Cloud Vision API via Firebase Functions
    // 3. Edamam Food Database API
    // 4. Nutritionix API
    // 5. Clarifai Food Recognition
    
    func recognizeFood(from image: UIImage) async throws -> RecognizedFood {
        // Simulate API call delay
        try await Task.sleep(nanoseconds: 1_500_000_000)
        
        // Mock response - in production, this would call an actual API
        // For demo purposes, return a common food item
        let mockFoods = [
            RecognizedFood(name: "Grilled Chicken Salad", calories: 350, protein: 35, carbs: 15, fat: 18, confidence: 0.85),
            RecognizedFood(name: "Avocado Toast", calories: 280, protein: 8, carbs: 28, fat: 16, confidence: 0.78),
            RecognizedFood(name: "Greek Yogurt with Berries", calories: 180, protein: 15, carbs: 22, fat: 4, confidence: 0.92),
            RecognizedFood(name: "Salmon with Vegetables", calories: 420, protein: 38, carbs: 20, fat: 22, confidence: 0.88),
            RecognizedFood(name: "Protein Smoothie", calories: 250, protein: 25, carbs: 30, fat: 5, confidence: 0.75),
        ]
        
        return mockFoods.randomElement()!
    }
    
    func recognizeMeal(from image: UIImage) async throws -> RecognizedMeal {
        // Simulate API call delay
        try await Task.sleep(nanoseconds: 2_000_000_000)
        
        // Mock responses with ingredients - in production, this would call an actual AI API
        // that analyzes the image and breaks it down into ingredients with nutritional info
        let mockMeals = [
            RecognizedMeal(
                name: "Grilled Lamb & Chicken",
                ingredients: [
                    Ingredient.sampleLamb(),
                    Ingredient.sampleChicken(),
                    Ingredient.sampleOliveOil(),
                    Ingredient.sampleSalt()
                ],
                confidence: 0.88,
                analysis: "Combines rich protein from both lamb and chicken, offering iron and essential nutrients. However, lamb adds saturated fat and the meal lacks vegetables and fiber; sodium can be elevated if salted. Add greens, whole grains and trim fat to improve balance."
            ),
            RecognizedMeal(
                name: "Grilled Chicken Salad",
                ingredients: [
                    Ingredient(
                        id: UUID().uuidString,
                        name: "Chicken breast (5 oz, grilled)",
                        quantity: 1.0,
                        measurementType: .servings,
                        calories: 230,
                        protein: 43,
                        carbs: 0,
                        fat: 5,
                        sugar: 0,
                        fiber: 0,
                        sodium: 90
                    ),
                    Ingredient(
                        id: UUID().uuidString,
                        name: "Mixed greens (2 cups)",
                        quantity: 1.0,
                        measurementType: .servings,
                        calories: 20,
                        protein: 2,
                        carbs: 4,
                        fat: 0,
                        sugar: 2,
                        fiber: 2,
                        sodium: 30
                    ),
                    Ingredient(
                        id: UUID().uuidString,
                        name: "Cherry tomatoes (0.5 cup)",
                        quantity: 1.0,
                        measurementType: .servings,
                        calories: 25,
                        protein: 1,
                        carbs: 5,
                        fat: 0,
                        sugar: 3,
                        fiber: 1,
                        sodium: 5
                    ),
                    Ingredient(
                        id: UUID().uuidString,
                        name: "Olive oil vinaigrette (1 tbsp)",
                        quantity: 1.0,
                        measurementType: .servings,
                        calories: 75,
                        protein: 0,
                        carbs: 1,
                        fat: 8,
                        sugar: 0,
                        fiber: 0,
                        sodium: 120
                    ),
                ],
                confidence: 0.85,
                analysis: "Excellent high-protein meal with lean chicken and fresh vegetables. Good balance of nutrients with healthy fats from olive oil. Rich in vitamins and minerals from the greens and tomatoes. Consider adding complex carbs like quinoa for a more complete meal."
            ),
            RecognizedMeal(
                name: "Avocado Toast with Eggs",
                ingredients: [
                    Ingredient(
                        id: UUID().uuidString,
                        name: "Whole grain bread (2 slices)",
                        quantity: 1.0,
                        measurementType: .servings,
                        calories: 160,
                        protein: 8,
                        carbs: 28,
                        fat: 2,
                        sugar: 4,
                        fiber: 4,
                        sodium: 280
                    ),
                    Ingredient(
                        id: UUID().uuidString,
                        name: "Avocado (0.5 medium)",
                        quantity: 1.0,
                        measurementType: .servings,
                        calories: 120,
                        protein: 1.5,
                        carbs: 6,
                        fat: 11,
                        sugar: 0.5,
                        fiber: 5,
                        sodium: 5
                    ),
                    Ingredient(
                        id: UUID().uuidString,
                        name: "Eggs (2 large, poached)",
                        quantity: 1.0,
                        measurementType: .servings,
                        calories: 140,
                        protein: 12,
                        carbs: 1,
                        fat: 10,
                        sugar: 0.5,
                        fiber: 0,
                        sodium: 140
                    ),
                ],
                confidence: 0.78,
                analysis: "Nutritious breakfast with healthy fats from avocado, quality protein from eggs, and fiber from whole grain bread. Well-balanced macronutrients. The combination provides sustained energy and keeps you full longer."
            ),
            RecognizedMeal(
                name: "Salmon with Vegetables",
                ingredients: [
                    Ingredient(
                        id: UUID().uuidString,
                        name: "Salmon fillet (6 oz, baked)",
                        quantity: 1.0,
                        measurementType: .servings,
                        calories: 350,
                        protein: 38,
                        carbs: 0,
                        fat: 20,
                        sugar: 0,
                        fiber: 0,
                        sodium: 90
                    ),
                    Ingredient(
                        id: UUID().uuidString,
                        name: "Broccoli (1 cup, steamed)",
                        quantity: 1.0,
                        measurementType: .servings,
                        calories: 55,
                        protein: 4,
                        carbs: 11,
                        fat: 0.5,
                        sugar: 2,
                        fiber: 5,
                        sodium: 40
                    ),
                    Ingredient(
                        id: UUID().uuidString,
                        name: "Sweet potato (1 medium, roasted)",
                        quantity: 1.0,
                        measurementType: .servings,
                        calories: 105,
                        protein: 2,
                        carbs: 24,
                        fat: 0,
                        sugar: 7,
                        fiber: 4,
                        sodium: 40
                    ),
                ],
                confidence: 0.88,
                analysis: "Excellent omega-3 rich meal with high-quality protein from salmon. Packed with nutrients from colorful vegetables. Great balance of protein, complex carbs, and healthy fats. Anti-inflammatory and heart-healthy choice."
            ),
        ]
        
        return mockMeals.randomElement()!
    }
}
