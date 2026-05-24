import Foundation
import SwiftData

enum HabitEntryPersistence {
    static func photoEntry(from entries: [HabitEntry], dateString: String) -> HabitEntry? {
        preferredPhotoEntry(from: entries.filter { $0.dateString == dateString })
    }

    static func preferredPhotoEntry(from entries: [HabitEntry]) -> HabitEntry? {
        preferredEntry(from: entries.filter { $0.imageUri != nil })
    }

    static func savePhoto(data: Data, habit: Habit, dateString: String, modelContext: ModelContext) throws {
        let existing = try resolveEntry(for: habit, dateString: dateString, modelContext: modelContext)
        let previousPhotoURL = photoFileURL(from: existing?.imageUri)
        let fileURL = try HabitPhotoFileStore.persistJPEG(
            data: data,
            habitID: habit.id,
            dateString: dateString
        )

        do {
            if let existing {
                existing.imageUri = fileURL.absoluteString
            } else {
                let newEntry = HabitEntry(
                    dateString: dateString,
                    imageUri: fileURL.absoluteString,
                    habit: habit
                )
                modelContext.insert(newEntry)
            }
            try modelContext.save()
        } catch {
            modelContext.rollback()
            try? FileManager.default.removeItem(at: fileURL)
            throw error
        }

        removePhotoFiles([previousPhotoURL].compactMap { $0 }, excluding: fileURL)
    }

    static func deleteEntries(for habit: Habit, dateString: String, modelContext: ModelContext) throws {
        let entries = try fetchEntries(for: habit, dateString: dateString, modelContext: modelContext)
        guard !entries.isEmpty else { return }

        let photoURLs = entries.compactMap { photoFileURL(from: $0.imageUri) }
        for entry in entries {
            modelContext.delete(entry)
        }
        do {
            try modelContext.save()
        } catch {
            modelContext.rollback()
            throw error
        }

        removePhotoFiles(photoURLs)
    }

    private static func resolveEntry(for habit: Habit, dateString: String, modelContext: ModelContext) throws -> HabitEntry? {
        let entries = try fetchEntries(for: habit, dateString: dateString, modelContext: modelContext)
        guard entries.count > 1 else { return entries.first }
        guard let keeper = preferredEntry(from: entries) else { return nil }

        let removedPhotoURLs = entries
            .filter { $0.id != keeper.id }
            .compactMap { photoFileURL(from: $0.imageUri) }
        let keeperURL = photoFileURL(from: keeper.imageUri)

        for entry in entries where entry.id != keeper.id {
            modelContext.delete(entry)
        }
        do {
            try modelContext.save()
        } catch {
            modelContext.rollback()
            throw error
        }

        removePhotoFiles(removedPhotoURLs, excluding: keeperURL)
        return keeper
    }

    private static func fetchEntries(for habit: Habit, dateString: String, modelContext: ModelContext) throws -> [HabitEntry] {
        let habitId = habit.id
        let predicate = #Predicate<HabitEntry> { entry in
            entry.dateString == dateString && entry.habit?.id == habitId
        }
        let descriptor = FetchDescriptor<HabitEntry>(predicate: predicate)
        return try modelContext.fetch(descriptor)
    }

    private static func preferredEntry(from entries: [HabitEntry]) -> HabitEntry? {
        entries.max { lhs, rhs in
            let lhsHasPhoto = lhs.imageUri != nil
            let rhsHasPhoto = rhs.imageUri != nil
            if lhsHasPhoto != rhsHasPhoto {
                return !lhsHasPhoto && rhsHasPhoto
            }

            let lhsModifiedAt = photoModifiedAt(for: lhs) ?? .distantPast
            let rhsModifiedAt = photoModifiedAt(for: rhs) ?? .distantPast
            if lhsModifiedAt != rhsModifiedAt {
                return lhsModifiedAt < rhsModifiedAt
            }

            return false
        }
    }

    private static func photoModifiedAt(for entry: HabitEntry) -> Date? {
        guard let url = photoFileURL(from: entry.imageUri) else { return nil }
        let attributes = try? FileManager.default.attributesOfItem(atPath: url.path)
        return attributes?[.modificationDate] as? Date
    }

    private static func photoFileURL(from uri: String?) -> URL? {
        guard let uri, let url = URL(string: uri), url.isFileURL else { return nil }
        return url
    }

    private static func removePhotoFiles(_ urls: [URL], excluding excludedURL: URL? = nil) {
        var removed = Set<String>()
        let excludedPath = excludedURL?.standardizedFileURL.path

        for url in urls {
            let path = url.standardizedFileURL.path
            guard path != excludedPath, removed.insert(path).inserted else { continue }
            try? FileManager.default.removeItem(at: url)
        }
    }
}
