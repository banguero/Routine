import UIKit

extension UIImage {
    /// Resizes the image to fit within the specified max dimension while maintaining aspect ratio
    /// - Parameter maxDimension: Maximum width or height in points
    /// - Returns: Resized image, or self if already smaller than max dimension
    func resized(to maxDimension: CGFloat) -> UIImage {
        let maxCurrentDimension = max(size.width, size.height)
        
        // If image is already smaller than max dimension, return as-is
        guard maxCurrentDimension > maxDimension else {
            return self
        }
        
        let scale = maxDimension / maxCurrentDimension
        let newWidth = size.width * scale
        let newHeight = size.height * scale
        
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: newWidth, height: newHeight))
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: CGSize(width: newWidth, height: newHeight)))
        }
    }
    
    /// Resizes the image to the specified size
    /// - Parameter targetSize: The target size
    /// - Returns: Resized image
    func resized(to targetSize: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }
}
