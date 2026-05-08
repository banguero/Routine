// StorageService.swift
// Requires FirebaseStorage

import Foundation
import UIKit
import FirebaseStorage

class StorageService {
    private let storage = FirebaseManager.shared.storage
    
    func uploadFoodImage(_ image: UIImage, userId: String) async throws -> String {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw StorageError.invalidImageData
        }
        
        let filename = "\(UUID().uuidString).jpg"
        let ref = storage.reference().child("\(userId)/food/\(filename)")
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        _ = try await ref.putDataAsync(imageData, metadata: metadata)
        let downloadURL = try await ref.downloadURL()
        
        return downloadURL.absoluteString
    }
    
    func deleteImage(url: String) async throws {
        let ref = storage.reference(forURL: url)
        try await ref.delete()
    }
}

enum StorageError: Error {
    case invalidImageData
    case uploadFailed
}
