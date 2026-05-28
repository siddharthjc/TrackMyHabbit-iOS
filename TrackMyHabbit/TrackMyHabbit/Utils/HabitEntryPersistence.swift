import Foundation
import SwiftData

enum HabitEntryPersistence {
    static func savePhoto(data: Data, habit: Habit, dateString: String, in modelContext: ModelContext) throws {
        let fileURL = try HabitPhotoFileStore.persistJPEG(
            data: data,
            habitID: habit.id,
            dateString: dateString
        )

        let entries = entries(for: habit, dateString: dateString, in: modelContext)
        let existing = entries.first
        let duplicates = entries.dropFirst()
        var filesToDeleteAfterSave = Set<String>()

        if let oldURI = existing?.imageUri, oldURI != fileURL.absoluteString {
            filesToDeleteAfterSave.insert(oldURI)
        }

        for duplicate in duplicates {
            if let uri = duplicate.imageUri, uri != fileURL.absoluteString {
                filesToDeleteAfterSave.insert(uri)
            }
        }

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

            for duplicate in duplicates {
                modelContext.delete(duplicate)
            }

            try modelContext.save()
            deleteFiles(at: filesToDeleteAfterSave)
        } catch {
            modelContext.rollback()
            try? FileManager.default.removeItem(at: fileURL)
            throw error
        }
    }

    static func deleteEntries(for habit: Habit, dateString: String, in modelContext: ModelContext) throws {
        let entries = entries(for: habit, dateString: dateString, in: modelContext)
        guard !entries.isEmpty else { return }

        let filesToDeleteAfterSave = Set(entries.compactMap(\.imageUri))

        do {
            for entry in entries {
                modelContext.delete(entry)
            }

            try modelContext.save()
            deleteFiles(at: filesToDeleteAfterSave)
        } catch {
            modelContext.rollback()
            throw error
        }
    }

    private static func entries(for habit: Habit, dateString: String, in modelContext: ModelContext) -> [HabitEntry] {
        do {
            let habitID = habit.id
            let predicate = #Predicate<HabitEntry> { entry in
                entry.dateString == dateString && entry.habit?.id == habitID
            }
            let descriptor = FetchDescriptor<HabitEntry>(predicate: predicate)
            return try modelContext.fetch(descriptor)
        } catch {
            return habit.entries.filter { $0.dateString == dateString }
        }
    }

    private static func deleteFiles(at uriStrings: Set<String>) {
        for uriString in uriStrings {
            guard let url = URL(string: uriString) else { continue }
            try? FileManager.default.removeItem(at: url)
        }
    }
}
