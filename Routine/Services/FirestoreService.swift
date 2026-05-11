// FirestoreService.swift
// Requires FirebaseFirestore

import Foundation
import Combine
import FirebaseFirestore

class FirestoreService {
    private let db = FirebaseManager.shared.db
    
    // MARK: - Food Entries
    
    func addFoodEntry(_ entry: FoodEntry) async throws {
        let docId = entry.id ?? UUID().uuidString
        var data: [String: Any] = [
            "userId": entry.userId,
            "name": entry.name,
            "calories": entry.calories,
            "protein": entry.protein,
            "carbs": entry.carbs,
            "fat": entry.fat,
            "mealType": entry.mealType.rawValue,
            "date": Timestamp(date: entry.date),
            "imageUrl": entry.imageUrl as Any,
            "aiRecognized": entry.aiRecognized,
            "confidence": entry.confidence as Any,
            "createdAt": Timestamp(date: entry.createdAt)
        ]
        
        // Add ingredients if present
        if let ingredients = entry.ingredients, !ingredients.isEmpty {
            let ingredientsData = ingredients.map { ingredient -> [String: Any] in
                return [
                    "id": ingredient.id as Any,
                    "name": ingredient.name,
                    "quantity": ingredient.quantity,
                    "measurementType": ingredient.measurementType.rawValue,
                    "calories": ingredient.calories,
                    "protein": ingredient.protein,
                    "carbs": ingredient.carbs,
                    "fat": ingredient.fat,
                    "sugar": ingredient.sugar,
                    "fiber": ingredient.fiber,
                    "sodium": ingredient.sodium
                ]
            }
            data["ingredients"] = ingredientsData
        }
        
        // Add optional nutritional info
        data["sugar"] = entry.sugar as Any
        data["fiber"] = entry.fiber as Any
        data["sodium"] = entry.sodium as Any
        
        try await db.collection("foodEntries").document(docId).setData(data)
    }
    
    func getFoodEntries(userId: String, date: Date) -> AnyPublisher<[FoodEntry], Error> {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let query = db.collection("foodEntries")
            .whereField("userId", isEqualTo: userId)
            .whereField("date", isGreaterThanOrEqualTo: Timestamp(date: startOfDay))
            .whereField("date", isLessThan: Timestamp(date: endOfDay))
            .order(by: "date", descending: true)
        
        return QuerySnapshotPublisher(query: query)
            .tryMap { snapshot in
                snapshot.documents.compactMap { document in
                    self.foodEntry(from: document)
                }
            }
            .eraseToAnyPublisher()
    }
    
    private func foodEntry(from document: QueryDocumentSnapshot) -> FoodEntry? {
        let data = document.data()
        guard let userId = data["userId"] as? String,
              let name = data["name"] as? String,
              let calories = data["calories"] as? Double,
              let protein = data["protein"] as? Double,
              let carbs = data["carbs"] as? Double,
              let fat = data["fat"] as? Double,
              let mealTypeRaw = data["mealType"] as? String,
              let mealType = MealType(rawValue: mealTypeRaw),
              let timestamp = data["date"] as? Timestamp,
              let aiRecognized = data["aiRecognized"] as? Bool,
              let createdAtTimestamp = data["createdAt"] as? Timestamp else {
            return nil
        }
        
        // Parse ingredients if present
        var ingredients: [Ingredient]?
        if let ingredientsData = data["ingredients"] as? [[String: Any]] {
            ingredients = ingredientsData.compactMap { dict in
                guard let name = dict["name"] as? String,
                      let quantity = dict["quantity"] as? Double,
                      let measurementTypeRaw = dict["measurementType"] as? String,
                      let measurementType = MeasurementType(rawValue: measurementTypeRaw),
                      let calories = dict["calories"] as? Double,
                      let protein = dict["protein"] as? Double,
                      let carbs = dict["carbs"] as? Double,
                      let fat = dict["fat"] as? Double else {
                    return nil
                }
                
                return Ingredient(
                    id: dict["id"] as? String,
                    name: name,
                    quantity: quantity,
                    measurementType: measurementType,
                    calories: calories,
                    protein: protein,
                    carbs: carbs,
                    fat: fat,
                    sugar: dict["sugar"] as? Double ?? 0,
                    fiber: dict["fiber"] as? Double ?? 0,
                    sodium: dict["sodium"] as? Double ?? 0
                )
            }
        }
        
        return FoodEntry(
            id: document.documentID,
            userId: userId,
            name: name,
            calories: calories,
            protein: protein,
            carbs: carbs,
            fat: fat,
            mealType: mealType,
            date: timestamp.dateValue(),
            imageUrl: data["imageUrl"] as? String,
            aiRecognized: aiRecognized,
            confidence: data["confidence"] as? Double,
            createdAt: createdAtTimestamp.dateValue(),
            ingredients: ingredients,
            sugar: data["sugar"] as? Double,
            fiber: data["fiber"] as? Double,
            sodium: data["sodium"] as? Double
        )
    }
    
    func deleteFoodEntry(id: String) async throws {
        try await db.collection("foodEntries").document(id).delete()
    }
    
    // MARK: - Water Entries
    
    func addWaterEntry(_ entry: WaterEntry) async throws {
        let docId = entry.id ?? UUID().uuidString
        let data: [String: Any] = [
            "userId": entry.userId,
            "amountOz": entry.amountOz,
            "date": Timestamp(date: entry.date),
            "createdAt": Timestamp(date: entry.createdAt)
        ]
        try await db.collection("waterEntries").document(docId).setData(data)
    }
    
    func getWaterEntries(userId: String, date: Date) -> AnyPublisher<[WaterEntry], Error> {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let query = db.collection("waterEntries")
            .whereField("userId", isEqualTo: userId)
            .whereField("date", isGreaterThanOrEqualTo: Timestamp(date: startOfDay))
            .whereField("date", isLessThan: Timestamp(date: endOfDay))
            .order(by: "date", descending: true)
        
        return QuerySnapshotPublisher(query: query)
            .tryMap { snapshot in
                snapshot.documents.compactMap { document in
                    self.waterEntry(from: document)
                }
            }
            .eraseToAnyPublisher()
    }
    
    private func waterEntry(from document: QueryDocumentSnapshot) -> WaterEntry? {
        let data = document.data()
        guard let userId = data["userId"] as? String,
              let amountOz = data["amountOz"] as? Double,
              let timestamp = data["date"] as? Timestamp,
              let createdAtTimestamp = data["createdAt"] as? Timestamp else {
            return nil
        }
        
        return WaterEntry(
            id: document.documentID,
            userId: userId,
            amountOz: amountOz,
            date: timestamp.dateValue(),
            createdAt: createdAtTimestamp.dateValue()
        )
    }
    
    // MARK: - User
    
    func getUser(userId: String) async throws -> User {
        let document = try await db.collection("users").document(userId).getDocument()
        guard let data = document.data(),
              let email = data["email"] as? String,
              let createdAtTimestamp = data["createdAt"] as? Timestamp else {
            throw NSError(domain: "FirestoreService", code: 404, userInfo: [NSLocalizedDescriptionKey: "User not found"])
        }
        
        return User(
            id: document.documentID,
            email: email,
            displayName: data["displayName"] as? String,
            appleUserId: data["appleUserId"] as? String,
            createdAt: createdAtTimestamp.dateValue(),
            dailyCalorieGoal: data["dailyCalorieGoal"] as? Int ?? 2000,
            dailyProteinGoal: data["dailyProteinGoal"] as? Int ?? 150,
            dailyCarbsGoal: data["dailyCarbsGoal"] as? Int ?? 250,
            dailyFatGoal: data["dailyFatGoal"] as? Int ?? 65,
            dailyWaterGoalOz: data["dailyWaterGoalOz"] as? Int ?? 64
        )
    }
    
    func updateUser(_ user: User) async throws {
        guard let userId = user.id else { return }
        let data: [String: Any] = [
            "email": user.email,
            "displayName": user.displayName as Any,
            "appleUserId": user.appleUserId as Any,
            "createdAt": Timestamp(date: user.createdAt),
            "dailyCalorieGoal": user.dailyCalorieGoal,
            "dailyProteinGoal": user.dailyProteinGoal,
            "dailyCarbsGoal": user.dailyCarbsGoal,
            "dailyFatGoal": user.dailyFatGoal,
            "dailyWaterGoalOz": user.dailyWaterGoalOz
        ]
        try await db.collection("users").document(userId).setData(data, merge: true)
    }
}

// MARK: - Combine Publisher for Firestore Queries
struct QuerySnapshotPublisher: Publisher {
    typealias Output = QuerySnapshot
    typealias Failure = Error
    
    private let query: Query
    
    init(query: Query) {
        self.query = query
    }
    
    func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {
        let subscription = QuerySnapshotSubscription(subscriber: subscriber, query: query)
        subscriber.receive(subscription: subscription)
    }
}

private final class QuerySnapshotSubscription<S: Subscriber>: Subscription where S.Input == QuerySnapshot, S.Failure == Error {
    private var subscriber: S?
    private var listener: ListenerRegistration?
    
    init(subscriber: S, query: Query) {
        self.subscriber = subscriber
        self.listener = query.addSnapshotListener { snapshot, error in
            if let error = error {
                subscriber.receive(completion: .failure(error))
            } else if let snapshot = snapshot {
                _ = subscriber.receive(snapshot)
            }
        }
    }
    
    func request(_ demand: Subscribers.Demand) {}
    
    func cancel() {
        listener?.remove()
        subscriber = nil
    }
}
