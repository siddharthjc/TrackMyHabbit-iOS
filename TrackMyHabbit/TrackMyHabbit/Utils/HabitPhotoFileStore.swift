import Foundation
import UIKit

enum HabitPhotoFileStore {
    struct PersistedJPEG {
        let fileURL: URL

        private let backupURL: URL?
        private let fileManager: FileManager

        func commit() {
            guard let backupURL else { return }
            try? fileManager.removeItem(at: backupURL)
        }

        func rollback() {
            if fileManager.fileExists(atPath: fileURL.path) {
                try? fileManager.removeItem(at: fileURL)
            }

            guard let backupURL,
                  fileManager.fileExists(atPath: backupURL.path) else {
                return
            }

            try? fileManager.moveItem(at: backupURL, to: fileURL)
        }
    }

    static func persistJPEG(data: Data, habitID: UUID, dateString: String) throws -> URL {
        let persisted = try persistJPEGTransaction(data: data, habitID: habitID, dateString: dateString)
        persisted.commit()
        return persisted.fileURL
    }

    static func persistJPEGTransaction(data: Data, habitID: UUID, dateString: String) throws -> PersistedJPEG {
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

        let fileURL = photoDirectory.appendingPathComponent("\(dateString).jpg")
        let backupURL = try backupExistingFile(at: fileURL, fileManager: fileManager)
        let encodedData = normalizedJPEGData(from: data) ?? data
        do {
            try encodedData.write(to: fileURL, options: .atomic)
        } catch {
            if let backupURL {
                try? fileManager.removeItem(at: backupURL)
            }
            throw error
        }

        return PersistedJPEG(fileURL: fileURL, backupURL: backupURL, fileManager: fileManager)
    }

    private static func normalizedJPEGData(from data: Data) -> Data? {
        guard let image = UIImage(data: data) else {
            return nil
        }
        return image.jpegData(compressionQuality: 0.9)
    }

    private static func backupExistingFile(at fileURL: URL, fileManager: FileManager) throws -> URL? {
        guard fileManager.fileExists(atPath: fileURL.path) else {
            return nil
        }

        let backupURL = fileManager.temporaryDirectory
            .appendingPathComponent("HabitPhotoBackup-\(UUID().uuidString).jpg")
        try fileManager.copyItem(at: fileURL, to: backupURL)
        return backupURL
    }
}
