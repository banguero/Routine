import Foundation

struct DailySummary: Codable {
    var userId: String
    var date: Date
    var totalCalories: Double
    var totalProtein: Double
    var totalCarbs: Double
    var totalFat: Double
    var totalWaterOz: Double
    var calorieGoal: Int
    var proteinGoal: Int
    var carbsGoal: Int
    var fatGoal: Int
    var waterGoalOz: Int
    
    var caloriesRemaining: Double {
        Double(calorieGoal) - totalCalories
    }
    
    var proteinRemaining: Double {
        Double(proteinGoal) - totalProtein
    }
    
    var carbsRemaining: Double {
        Double(carbsGoal) - totalCarbs
    }
    
    var fatRemaining: Double {
        Double(fatGoal) - totalFat
    }
    
    var waterRemaining: Double {
        Double(waterGoalOz) - totalWaterOz
    }
}
