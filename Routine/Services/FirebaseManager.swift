// FirebaseManager.swift

import Foundation
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth

class FirebaseManager {
    static let shared = FirebaseManager()
    
    let db: Firestore
    let storage: Storage
    let auth: Auth
    
    private init() {
        self.db = Firestore.firestore()
        self.storage = Storage.storage()
        self.auth = Auth.auth()
        
        // Configure Firestore for offline persistence
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = true
        settings.cacheSizeBytes = FirestoreCacheSizeUnlimited
        db.settings = settings
    }
}
