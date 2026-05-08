// WaterViewModel.swift

import Foundation
import Combine

@MainActor
class WaterViewModel: ObservableObject {
    @Published var waterEntries: [WaterEntry] = []
    @Published var totalWaterOz: Double = 0
    
    private let firestoreService = FirestoreService()
    private var cancellables = Set<AnyCancellable>()
    private var userId: String
    
    init(userId: String) {
        self.userId = userId
        subscribeToWaterEntries()
    }
    
    func updateUserId(_ userId: String) {
        self.userId = userId
        // Resubscribe with new user
        cancellables.removeAll()
        subscribeToWaterEntries()
    }
    
    func subscribeToWaterEntries(date: Date = Date()) {
        firestoreService.getWaterEntries(userId: userId, date: date)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in }, receiveValue: { entries in
                if !entries.isEmpty {
                    self.waterEntries = entries
                }
                self.totalWaterOz = self.waterEntries.reduce(0) { $0 + $1.amountOz }
            })
            .store(in: &cancellables)
    }
    
    func addWater(amountOz: Double) async {
        let entry = WaterEntry(userId: userId, amountOz: amountOz)
        
        // Add to local array immediately
        waterEntries.append(entry)
        totalWaterOz += amountOz
        
        // Save to Firestore
        try? await firestoreService.addWaterEntry(entry)
    }
    
    private func loadMockData() {
        // Mock data for development
        if waterEntries.isEmpty {
            waterEntries = [
                WaterEntry(userId: userId, amountOz: 8, date: Date()),
                WaterEntry(userId: userId, amountOz: 12, date: Date().addingTimeInterval(-1800)),
                WaterEntry(userId: userId, amountOz: 8, date: Date().addingTimeInterval(-3600))
            ]
            totalWaterOz = waterEntries.reduce(0) { $0 + $1.amountOz }
        }
    }
}
