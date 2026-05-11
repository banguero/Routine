import Foundation

enum MeasurementType: String, Codable, CaseIterable {
    case servings = "servings"
    case grams = "grams"
    case ounces = "ounces"
    case cups = "cups"
    case tablespoons = "tbsp"
    case teaspoons = "tsp"
    case pieces = "pieces"
    case milliliters = "ml"
    case liters = "l"
    
    var abbreviation: String {
        switch self {
        case .servings: return "servings"
        case .grams: return "g"
        case .ounces: return "oz"
        case .cups: return "cups"
        case .tablespoons: return "tbsp"
        case .teaspoons: return "tsp"
        case .pieces: return "pieces"
        case .milliliters: return "ml"
        case .liters: return "l"
        }
    }
    
    var displayName: String {
        return self.rawValue
    }
}

struct Ingredient: Codable, Identifiable, Equatable {
    var id: String?
    var name: String
    var quantity: Double
    var measurementType: MeasurementType
    
    // Nutritional info per the specified quantity
    var calories: Double
    var protein: Double // in grams
    var carbs: Double   // in grams
    var fat: Double     // in grams
    var sugar: Double   // in grams
    var fiber: Double   // in grams
    var sodium: Double  // in mg
    
    init(id: String? = nil, name: String, quantity: Double = 1.0,
         measurementType: MeasurementType = .servings,
         calories: Double, protein: Double, carbs: Double, fat: Double,
         sugar: Double = 0, fiber: Double = 0, sodium: Double = 0) {
        self.id = id
        self.name = name
        self.quantity = quantity
        self.measurementType = measurementType
        self.calories = calories
        self.protein = protein
        self.carbs = carbs
        self.fat = fat
        self.sugar = sugar
        self.fiber = fiber
        self.sodium = sodium
    }
    
    // Helper to create a copy with updated quantity (scales nutrition proportionally)
    func withQuantity(_ newQuantity: Double) -> Ingredient {
        let ratio = newQuantity / self.quantity
        return Ingredient(
            id: self.id,
            name: self.name,
            quantity: newQuantity,
            measurementType: self.measurementType,
            calories: self.calories * ratio,
            protein: self.protein * ratio,
            carbs: self.carbs * ratio,
            fat: self.fat * ratio,
            sugar: self.sugar * ratio,
            fiber: self.fiber * ratio,
            sodium: self.sodium * ratio
        )
    }
    
    // Display string for the ingredient (e.g., "Lamb (4 oz, cooked)")
    var displayName: String {
        return name
    }
    
    // Formatted quantity string (e.g., "1.0 servings")
    var quantityString: String {
        let formattedQuantity = quantity.truncatingRemainder(dividingBy: 1) == 0 ? 
            String(format: "%.0f", quantity) : String(format: "%.1f", quantity)
        return "\(formattedQuantity) \(measurementType.abbreviation)"
    }
}

// MARK: - Sample Ingredients for Testing
extension Ingredient {
    static func sampleLamb() -> Ingredient {
        return Ingredient(
            id: "1",
            name: "Lamb (4 oz, cooked)",
            quantity: 1.0,
            measurementType: .servings,
            calories: 320,
            protein: 24,
            carbs: 0,
            fat: 24,
            sugar: 0,
            fiber: 0,
            sodium: 70
        )
    }
    
    static func sampleChicken() -> Ingredient {
        return Ingredient(
            id: "2",
            name: "Chicken breast (4 oz, cooked)",
            quantity: 1.0,
            measurementType: .servings,
            calories: 165,
            protein: 31,
            carbs: 0,
            fat: 4,
            sugar: 0,
            fiber: 0,
            sodium: 75
        )
    }
    
    static func sampleOliveOil() -> Ingredient {
        return Ingredient(
            id: "3",
            name: "Olive oil (1 tsp)",
            quantity: 1.0,
            measurementType: .servings,
            calories: 40,
            protein: 0,
            carbs: 0,
            fat: 5,
            sugar: 0,
            fiber: 0,
            sodium: 0
        )
    }
    
    static func sampleSalt() -> Ingredient {
        return Ingredient(
            id: "4",
            name: "Salt & seasonings (0.25 tsp salt + spices)",
            quantity: 1.0,
            measurementType: .servings,
            calories: 0,
            protein: 0,
            carbs: 0,
            fat: 0,
            sugar: 0,
            fiber: 0,
            sodium: 580
        )
    }
}
