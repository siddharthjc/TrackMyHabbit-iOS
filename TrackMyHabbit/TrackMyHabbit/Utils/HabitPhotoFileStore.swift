import Foundation
import UIKit

enum HabitPhotoFileStore {
    static func persistJPEG(data: Data, habitID: UUID, dateString: String) throws -> URL {
        let photoDirectory = try photoDirectory(for: habitID)
        let fileURL = photoDirectory.appendingPathComponent("\(dateString)-\(UUID().uuidString).jpg")
        let encodedData = normalizedJPEGData(from: data) ?? data
        try encodedData.write(to: fileURL, options: .atomic)
        return fileURL
    }

    /// Removes the on-disk photo namespace for a habit after the habit row is deleted.
    static func deleteAllPhotos(for habitID: UUID) throws {
        let photoDirectory = try photoDirectory(for: habitID, create: false)
        guard FileManager.default.fileExists(atPath: photoDirectory.path) else { return }
        try FileManager.default.removeItem(at: photoDirectory)
    }

    private static func photoDirectory(for habitID: UUID, create: Bool = true) throws -> URL {
        let fileManager = FileManager.default
        let appSupportURL = try fileManager.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: create
        )
        let photoDirectory = appSupportURL
            .appendingPathComponent("HabitPhotos", isDirectory: true)
            .appendingPathComponent(habitID.uuidString, isDirectory: true)

        guard create else { return photoDirectory }
        try fileManager.createDirectory(at: photoDirectory, withIntermediateDirectories: true)
        return photoDirectory
    }

    private static func normalizedJPEGData(from data: Data) -> Data? {
        guard let image = UIImage(data: data) else {
            return nil
        }
        return image.jpegData(compressionQuality: 0.9)
    }
}
