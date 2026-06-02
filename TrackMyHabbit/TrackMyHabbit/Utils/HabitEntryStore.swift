import Foundation
import SwiftData

enum HabitEntryStore {
    static func preferredEntry(in entries: [HabitEntry], dateString: String) -> HabitEntry? {
        preferredEntry(in: entries.filter { $0.dateString == dateString })
    }

    static func preferredEntry(in entries: [HabitEntry]) -> HabitEntry? {
        entries.first(where: { $0.imageUri != nil }) ?? entries.first
    }

    static func savePhoto(
        _ data: Data,
        habit: Habit,
        dateString: String,
        modelContext: ModelContext
    ) throws {
        let fileURL = try HabitPhotoFileStore.persistJPEG(
            data: data,
            habitID: habit.id,
            dateString: dateString
        )

        do {
            let entries = try fetchEntries(habit: habit, dateString: dateString, modelContext: modelContext)
            let entry = preferredEntry(in: entries)
            let oldPhotoURLs = entries.compactMap(\.photoFileURL)

            if let entry {
                entry.imageUri = fileURL.absoluteString
                for duplicate in entries where duplicate !== entry {
                    modelContext.delete(duplicate)
                }
            } else {
                let newEntry = HabitEntry(
                    dateString: dateString,
                    imageUri: fileURL.absoluteString,
                    habit: habit
                )
                modelContext.insert(newEntry)
            }

            try modelContext.save()
            removePhotoFiles(at: oldPhotoURLs, excluding: fileURL)
        } catch {
            modelContext.rollback()
            try? FileManager.default.removeItem(at: fileURL)
            throw error
        }
    }

    static func deleteEntries(
        habit: Habit,
        dateString: String,
        modelContext: ModelContext
    ) throws {
        let entries = try fetchEntries(habit: habit, dateString: dateString, modelContext: modelContext)
        guard !entries.isEmpty else { return }

        let photoURLs = entries.compactMap(\.photoFileURL)
        for entry in entries {
            modelContext.delete(entry)
        }

        do {
            try modelContext.save()
            removePhotoFiles(at: photoURLs)
        } catch {
            modelContext.rollback()
            throw error
        }
    }

    private static func fetchEntries(
        habit: Habit,
        dateString: String,
        modelContext: ModelContext
    ) throws -> [HabitEntry] {
        let habitId = habit.id
        let predicate = #Predicate<HabitEntry> { entry in
            entry.dateString == dateString && entry.habit?.id == habitId
        }
        let descriptor = FetchDescriptor<HabitEntry>(predicate: predicate)
        return try modelContext.fetch(descriptor)
    }

    private static func removePhotoFiles(at urls: [URL], excluding retainedURL: URL? = nil) {
        let uniqueURLs = Set(urls)
        for url in uniqueURLs where url != retainedURL {
            try? FileManager.default.removeItem(at: url)
        }
    }
}

private extension HabitEntry {
    var photoFileURL: URL? {
        guard let imageUri else { return nil }
        return URL(string: imageUri)
    }
}
