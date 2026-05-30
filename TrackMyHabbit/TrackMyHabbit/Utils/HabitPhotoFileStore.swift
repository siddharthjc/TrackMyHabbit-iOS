import Foundation
import UIKit

enum HabitPhotoFileStore {
    static func persistJPEG(data: Data, habitID: UUID, dateString: String) throws -> URL {
        let fileManager = FileManager.default
        let appSupportURL = try fileManager.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        let photoDirectory = appSupportURL
            .appendingPathComponent("HabitPhotos", isDirectory: true)
            .appendingPathComponent(habitID.uuidString, isDirectory: true)

        try fileManager.createDirectory(at: photoDirectory, withIntermediateDirectories: true)

        let fileURL = photoDirectory.appendingPathComponent("\(dateString)-\(UUID().uuidString).jpg")
        let encodedData = normalizedJPEGData(from: data) ?? data
        try encodedData.write(to: fileURL, options: .atomic)
        return fileURL
    }

    static func removePhoto(at url: URL) {
        guard url.isFileURL else { return }
        try? FileManager.default.removeItem(at: url)
    }

    static func removePhoto(uri: String?) {
        guard let uri, let url = URL(string: uri) else { return }
        removePhoto(at: url)
    }

    static func removeReplacedPhoto(uri: String?, keeping currentURL: URL) {
        guard let uri, let replacedURL = URL(string: uri) else { return }
        let replaced = replacedURL.standardizedFileURL
        let current = currentURL.standardizedFileURL
        guard replaced != current else { return }
        removePhoto(at: replacedURL)
    }

    private static func normalizedJPEGData(from data: Data) -> Data? {
        guard let image = UIImage(data: data) else {
            return nil
        }
        return image.jpegData(compressionQuality: 0.9)
    }
}
