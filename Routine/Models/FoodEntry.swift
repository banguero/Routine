import Foundation

enum MealType: String, Codable, CaseIterable {
    case breakfast = "Breakfast"
    case lunch = "Lunch"
    case dinner = "Dinner"
    case snack = "Snack"
}

struct FoodEntry: Codable, Identifiable {
    var id: String?
    var userId: String
    var name: String
    var calories: Double
    var protein: Double
    var carbs: Double
    var fat: Double
    var mealType: MealType
    var date: Date
    var imageUrl: String?
    var aiRecognized: Bool
    var confidence: Double?
    var createdAt: Date
    var ingredients: [Ingredient]?
    
    // Additional nutritional info (computed from ingredients or stored)
    var sugar: Double?
    var fiber: Double?
    var sodium: Double? // in mg
    
    init(id: String? = nil, userId: String, name: String, calories: Double,
         protein: Double, carbs: Double, fat: Double, mealType: MealType,
         date: Date = Date(), imageUrl: String? = nil, aiRecognized: Bool = false,
         confidence: Double? = nil, createdAt: Date = Date(),
         ingredients: [Ingredient]? = nil, sugar: Double? = nil,
         fiber: Double? = nil, sodium: Double? = nil) {
        self.id = id
        self.userId = userId
        self.name = name
        self.calories = calories
        self.protein = protein
        self.carbs = carbs
        self.fat = fat
        self.mealType = mealType
        self.date = date
        self.imageUrl = imageUrl
        self.aiRecognized = aiRecognized
        self.confidence = confidence
        self.createdAt = createdAt
        self.ingredients = ingredients
        self.sugar = sugar
        self.fiber = fiber
        self.sodium = sodium
    }
    
    // Computed properties for totals from ingredients
    var totalCalories: Double {
        if let ingredients = ingredients, !ingredients.isEmpty {
            return ingredients.reduce(0) { $0 + $1.calories }
        }
        return calories
    }
    
    var totalProtein: Double {
        if let ingredients = ingredients, !ingredients.isEmpty {
            return ingredients.reduce(0) { $0 + $1.protein }
        }
        return protein
    }
    
    var totalCarbs: Double {
        if let ingredients = ingredients, !ingredients.isEmpty {
            return ingredients.reduce(0) { $0 + $1.carbs }
        }
        return carbs
    }
    
    var totalFat: Double {
        if let ingredients = ingredients, !ingredients.isEmpty {
            return ingredients.reduce(0) { $0 + $1.fat }
        }
        return fat
    }
    
    var totalSugar: Double {
        if let ingredients = ingredients, !ingredients.isEmpty {
            return ingredients.reduce(0) { $0 + $1.sugar }
        }
        return sugar ?? 0
    }
    
    var totalFiber: Double {
        if let ingredients = ingredients, !ingredients.isEmpty {
            return ingredients.reduce(0) { $0 + $1.fiber }
        }
        return fiber ?? 0
    }
    
    var totalSodium: Double {
        if let ingredients = ingredients, !ingredients.isEmpty {
            return ingredients.reduce(0) { $0 + $1.sodium }
        }
        return sodium ?? 0
    }
    
    // Update macros from ingredients
    mutating func updateMacrosFromIngredients() {
        guard let ingredients = ingredients, !ingredients.isEmpty else { return }
        self.calories = ingredients.reduce(0) { $0 + $1.calories }
        self.protein = ingredients.reduce(0) { $0 + $1.protein }
        self.carbs = ingredients.reduce(0) { $0 + $1.carbs }
        self.fat = ingredients.reduce(0) { $0 + $1.fat }
        self.sugar = ingredients.reduce(0) { $0 + $1.sugar }
        self.fiber = ingredients.reduce(0) { $0 + $1.fiber }
        self.sodium = ingredients.reduce(0) { $0 + $1.sodium }
    }
}
