import Foundation
import SwiftData

enum HabitEntryStore {
    static func preferredEntry(for habit: Habit, dateString: String) -> HabitEntry? {
        preferredEntry(in: entries(for: habit, dateString: dateString))
    }

    static func preferredEntry(in entries: [HabitEntry]) -> HabitEntry? {
        entries.first(where: { $0.imageUri != nil }) ?? entries.first
    }

    static func duplicateEntries(in entries: [HabitEntry], keeping preferred: HabitEntry?) -> [HabitEntry] {
        guard let preferred else { return entries }
        return entries.filter { $0 !== preferred }
    }

    static func savePhoto(data: Data, habit: Habit, dateString: String, in modelContext: ModelContext) throws {
        let entries = resolvedEntries(for: habit, dateString: dateString, in: modelContext)
        let existing = preferredEntry(in: entries)
        let duplicateEntries = duplicateEntries(in: entries, keeping: existing)
        let oldPhotoURLs = photoURLs(from: duplicateEntries) + photoURLs(from: [existing].compactMap { $0 })
        let fileURL = try HabitPhotoFileStore.persistJPEG(
            data: data,
            habitID: habit.id,
            dateString: dateString
        )

        do {
            if let existing {
                existing.imageUri = fileURL.absoluteString
            } else {
                modelContext.insert(HabitEntry(
                    dateString: dateString,
                    imageUri: fileURL.absoluteString,
                    habit: habit
                ))
            }

            for duplicate in duplicateEntries {
                modelContext.delete(duplicate)
            }

            try modelContext.save()
        } catch {
            modelContext.rollback()
            try? FileManager.default.removeItem(at: fileURL)
            throw error
        }

        removeFiles(at: oldPhotoURLs.filter { $0 != fileURL })
    }

    static func deleteEntries(for habit: Habit, dateString: String, in modelContext: ModelContext) throws {
        let entries = resolvedEntries(for: habit, dateString: dateString, in: modelContext)
        guard !entries.isEmpty else { return }

        let oldPhotoURLs = photoURLs(from: entries)
        for entry in entries {
            modelContext.delete(entry)
        }

        do {
            try modelContext.save()
        } catch {
            modelContext.rollback()
            throw error
        }

        removeFiles(at: oldPhotoURLs)
    }

    private static func resolvedEntries(for habit: Habit, dateString: String, in modelContext: ModelContext) -> [HabitEntry] {
        do {
            let fetched = try fetchEntries(for: habit, dateString: dateString, in: modelContext)
            return fetched.isEmpty ? entries(for: habit, dateString: dateString) : fetched
        } catch {
            return entries(for: habit, dateString: dateString)
        }
    }

    private static func entries(for habit: Habit, dateString: String) -> [HabitEntry] {
        habit.entries.filter { $0.dateString == dateString }
    }

    private static func fetchEntries(for habit: Habit, dateString: String, in modelContext: ModelContext) throws -> [HabitEntry] {
        let habitId = habit.id
        let predicate = #Predicate<HabitEntry> { entry in
            entry.dateString == dateString && entry.habit?.id == habitId
        }
        return try modelContext.fetch(FetchDescriptor<HabitEntry>(predicate: predicate))
    }

    private static func photoURLs(from entries: [HabitEntry]) -> [URL] {
        entries.compactMap { entry in
            guard let uri = entry.imageUri else { return nil }
            return URL(string: uri)
        }
    }

    private static func removeFiles(at urls: [URL]) {
        var removed = Set<URL>()
        for url in urls where removed.insert(url).inserted {
            try? FileManager.default.removeItem(at: url)
        }
    }
}
