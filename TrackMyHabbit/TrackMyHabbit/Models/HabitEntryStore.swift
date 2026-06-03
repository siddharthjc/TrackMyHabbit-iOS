import Foundation
import SwiftData

enum HabitEntryStore {
    @discardableResult
    static func savePhoto(data: Data, habit: Habit, dateString: String, modelContext: ModelContext) throws -> URL {
        let fileURL = try HabitPhotoFileStore.persistJPEG(data: data, habitID: habit.id, dateString: dateString)

        do {
            let entries = try entries(for: habit, dateString: dateString, modelContext: modelContext)
            let existing = preferredEntry(from: entries)
            let staleURLs = urlsToRemoveAfterReplacing(entries: entries, keeping: existing, newFileURL: fileURL)

            if let existing {
                existing.imageUri = fileURL.absoluteString
                deleteDuplicates(in: entries, keeping: existing, modelContext: modelContext)
            } else {
                let newEntry = HabitEntry(
                    dateString: dateString,
                    imageUri: fileURL.absoluteString,
                    habit: habit
                )
                modelContext.insert(newEntry)
            }

            try modelContext.save()
            removeFiles(at: staleURLs)
            return fileURL
        } catch {
            modelContext.rollback()
            try? FileManager.default.removeItem(at: fileURL)
            throw error
        }
    }

    static func deleteEntries(for habit: Habit, dateString: String, modelContext: ModelContext) throws {
        let entries = try entries(for: habit, dateString: dateString, modelContext: modelContext)
        guard !entries.isEmpty else { return }

        let staleURLs = Set(entries.compactMap { fileURL(from: $0.imageUri) })
        entries.forEach { modelContext.delete($0) }

        do {
            try modelContext.save()
            removeFiles(at: staleURLs)
        } catch {
            modelContext.rollback()
            throw error
        }
    }

    private static func entries(for habit: Habit, dateString: String, modelContext: ModelContext) throws -> [HabitEntry] {
        let habitID = habit.id
        let predicate = #Predicate<HabitEntry> { entry in
            entry.dateString == dateString && entry.habit?.id == habitID
        }
        let descriptor = FetchDescriptor<HabitEntry>(predicate: predicate)
        return try modelContext.fetch(descriptor)
    }

    private static func preferredEntry(from entries: [HabitEntry]) -> HabitEntry? {
        entries.first(where: { $0.imageUri != nil }) ?? entries.first
    }

    private static func deleteDuplicates(in entries: [HabitEntry], keeping entryToKeep: HabitEntry, modelContext: ModelContext) {
        for entry in entries where entry !== entryToKeep {
            modelContext.delete(entry)
        }
    }

    private static func urlsToRemoveAfterReplacing(
        entries: [HabitEntry],
        keeping entryToKeep: HabitEntry?,
        newFileURL: URL
    ) -> Set<URL> {
        Set(entries.compactMap { entry in
            guard entry === entryToKeep else {
                return fileURL(from: entry.imageUri)
            }
            guard let oldURL = fileURL(from: entry.imageUri), oldURL != newFileURL else {
                return nil
            }
            return oldURL
        })
    }

    private static func fileURL(from uri: String?) -> URL? {
        guard let uri else { return nil }
        guard let url = URL(string: uri), url.isFileURL else { return nil }
        return url
    }

    private static func removeFiles(at urls: Set<URL>) {
        for url in urls {
            try? FileManager.default.removeItem(at: url)
        }
    }
}
