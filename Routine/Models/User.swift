import Foundation

struct User: Codable, Identifiable {
    var id: String?
    var email: String
    var displayName: String?
    var appleUserId: String?
    var createdAt: Date
    var dailyCalorieGoal: Int
    var dailyProteinGoal: Int
    var dailyCarbsGoal: Int
    var dailyFatGoal: Int
    var dailyWaterGoalOz: Int
    
    init(id: String? = nil, email: String, displayName: String? = nil,
         appleUserId: String? = nil, createdAt: Date = Date(),
         dailyCalorieGoal: Int = 2000, dailyProteinGoal: Int = 150,
         dailyCarbsGoal: Int = 250, dailyFatGoal: Int = 65,
         dailyWaterGoalOz: Int = 64) {
        self.id = id
        self.email = email
        self.displayName = displayName
        self.appleUserId = appleUserId
        self.createdAt = createdAt
        self.dailyCalorieGoal = dailyCalorieGoal
        self.dailyProteinGoal = dailyProteinGoal
        self.dailyCarbsGoal = dailyCarbsGoal
        self.dailyFatGoal = dailyFatGoal
        self.dailyWaterGoalOz = dailyWaterGoalOz
    }
}
