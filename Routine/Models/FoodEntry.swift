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
    
    init(id: String? = nil, userId: String, name: String, calories: Double,
         protein: Double, carbs: Double, fat: Double, mealType: MealType,
         date: Date = Date(), imageUrl: String? = nil, aiRecognized: Bool = false,
         confidence: Double? = nil, createdAt: Date = Date()) {
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
    }
}
