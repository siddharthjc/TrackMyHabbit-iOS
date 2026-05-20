import Foundation
import UIKit

enum HabitPhotoFileStore {
    static func persistJPEG(data: Data, habitID: UUID, dateString: String) throws -> URL {
        let photoDirectory = try photoDirectory(for: habitID, create: true)

        let fileURL = photoDirectory.appendingPathComponent(photoFileName(dateString: dateString))
        let encodedData = normalizedJPEGData(from: data) ?? data
        try encodedData.write(to: fileURL, options: .atomic)
        return fileURL
    }

    static func photoFileName(dateString: String, fileID: UUID = UUID()) -> String {
        "\(dateString)-\(fileID.uuidString).jpg"
    }

    static func removePhoto(at url: URL) {
        try? FileManager.default.removeItem(at: url)
    }

    static func removePhoto(at uri: String?) {
        guard let uri, let url = URL(string: uri) else { return }
        removePhoto(at: url)
    }

    static func removePhotos(at uris: [String]) {
        for uri in uris {
            removePhoto(at: uri)
        }
    }

    static func removePhotoDirectory(for habitID: UUID) {
        guard let directory = try? photoDirectory(for: habitID, create: false),
              FileManager.default.fileExists(atPath: directory.path) else {
            return
        }
        try? FileManager.default.removeItem(at: directory)
    }

    private static func photoDirectory(for habitID: UUID, create: Bool) throws -> URL {
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

        if create {
            try fileManager.createDirectory(at: photoDirectory, withIntermediateDirectories: true)
        }

        return photoDirectory
    }

    private static func normalizedJPEGData(from data: Data) -> Data? {
        guard let image = UIImage(data: data) else {
            return nil
        }
        return image.jpegData(compressionQuality: 0.9)
    }
}
