import Foundation

struct WaterEntry: Codable, Identifiable {
    var id: String?
    var userId: String
    var amountOz: Double
    var date: Date
    var createdAt: Date
    
    init(id: String? = nil, userId: String, amountOz: Double,
         date: Date = Date(), createdAt: Date = Date()) {
        self.id = id
        self.userId = userId
        self.amountOz = amountOz
        self.date = date
        self.createdAt = createdAt
    }
}
