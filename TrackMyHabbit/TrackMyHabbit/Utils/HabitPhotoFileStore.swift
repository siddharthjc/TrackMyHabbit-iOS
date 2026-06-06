import Foundation
import SwiftData
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

    private static func normalizedJPEGData(from data: Data) -> Data? {
        guard let image = UIImage(data: data) else {
            return nil
        }
        return image.jpegData(compressionQuality: 0.9)
    }
}

enum HabitEntryStore {
    static func savePhoto(data: Data, habit: Habit, dateString: String, in modelContext: ModelContext) throws {
        let fileURL = try HabitPhotoFileStore.persistJPEG(data: data, habitID: habit.id, dateString: dateString)
        let fileUri = fileURL.absoluteString

        do {
            let entries = fetchEntries(habit: habit, dateString: dateString, in: modelContext)
            let oldPhotoURLs = Set(entries.compactMap { photoURL(from: $0.imageUri) })
            let target = HabitEntry.preferredEntry(for: dateString, in: entries) ?? HabitEntry(dateString: dateString, habit: habit)

            if target.habit == nil {
                target.habit = habit
            }
            if !entries.contains(where: { $0 === target }) {
                modelContext.insert(target)
            }

            target.imageUri = fileUri
            for duplicate in entries where duplicate !== target {
                modelContext.delete(duplicate)
            }

            try modelContext.save()

            for url in oldPhotoURLs where url != fileURL {
                try? FileManager.default.removeItem(at: url)
            }
        } catch {
            modelContext.rollback()
            try? FileManager.default.removeItem(at: fileURL)
            throw error
        }
    }

    static func deleteEntries(habit: Habit, dateString: String, in modelContext: ModelContext) throws {
        let entries = fetchEntries(habit: habit, dateString: dateString, in: modelContext)
        guard !entries.isEmpty else { return }

        let photoURLs = Set(entries.compactMap { photoURL(from: $0.imageUri) })

        do {
            for entry in entries {
                modelContext.delete(entry)
            }
            try modelContext.save()

            for url in photoURLs {
                try? FileManager.default.removeItem(at: url)
            }
        } catch {
            modelContext.rollback()
            throw error
        }
    }

    private static func fetchEntries(habit: Habit, dateString: String, in modelContext: ModelContext) -> [HabitEntry] {
        do {
            let habitId = habit.id
            let predicate = #Predicate<HabitEntry> { entry in
                entry.dateString == dateString && entry.habit?.id == habitId
            }
            let descriptor = FetchDescriptor<HabitEntry>(predicate: predicate)
            let results = try modelContext.fetch(descriptor)
            return results.isEmpty ? fallbackEntries(habit: habit, dateString: dateString) : results
        } catch {
            return fallbackEntries(habit: habit, dateString: dateString)
        }
    }

    private static func fallbackEntries(habit: Habit, dateString: String) -> [HabitEntry] {
        habit.entries.filter { $0.dateString == dateString }
    }

    private static func photoURL(from uri: String?) -> URL? {
        guard let uri else { return nil }
        return URL(string: uri)
    }
}
