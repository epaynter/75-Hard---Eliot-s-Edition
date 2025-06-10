import Foundation
import UIKit

class PhotoManager {
    static let shared = PhotoManager()
    private let fileManager = FileManager.default
    
    private init() {}
    
    private var photosDirectory: URL {
        let paths = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0].appendingPathComponent("ProgressPhotos")
    }
    
    func savePhoto(_ image: UIImage, for date: Date) throws {
        // Create directory if it doesn't exist
        if !fileManager.fileExists(atPath: photosDirectory.path) {
            try fileManager.createDirectory(at: photosDirectory, withIntermediateDirectories: true)
        }
        
        // Generate filename from date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let filename = dateFormatter.string(from: date) + ".jpg"
        let fileURL = photosDirectory.appendingPathComponent(filename)
        
        // Convert image to data and save
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw NSError(domain: "PhotoManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image to data"])
        }
        
        try imageData.write(to: fileURL)
    }
    
    func loadPhoto(for date: Date) -> UIImage? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let filename = dateFormatter.string(from: date) + ".jpg"
        let fileURL = photosDirectory.appendingPathComponent(filename)
        
        guard let imageData = try? Data(contentsOf: fileURL) else {
            return nil
        }
        
        return UIImage(data: imageData)
    }
    
    func deletePhoto(for date: Date) throws {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let filename = dateFormatter.string(from: date) + ".jpg"
        let fileURL = photosDirectory.appendingPathComponent(filename)
        
        try fileManager.removeItem(at: fileURL)
    }
    
    func deleteAllPhotos() throws {
        if fileManager.fileExists(atPath: photosDirectory.path) {
            try fileManager.removeItem(at: photosDirectory)
        }
    }
}
