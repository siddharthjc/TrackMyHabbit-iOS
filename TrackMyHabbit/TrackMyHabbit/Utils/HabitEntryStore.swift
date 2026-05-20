import Foundation
import SwiftData

enum HabitEntryStore {
    static func preferredEntry(from entries: [HabitEntry]) -> HabitEntry? {
        entries.first(where: { $0.imageUri != nil }) ?? entries.first
    }

    @discardableResult
    static func upsertPhoto(
        habit: Habit,
        dateString: String,
        imageUri: String,
        in modelContext: ModelContext
    ) throws -> [String] {
        let entries = try entries(for: habit, dateString: dateString, in: modelContext)
        let stalePhotoURIs = uniquePhotoURIs(from: entries, excluding: imageUri)

        if let existing = preferredEntry(from: entries) {
            existing.imageUri = imageUri
            deleteDuplicates(in: entries, keeping: existing, in: modelContext)
        } else {
            let newEntry = HabitEntry(
                dateString: dateString,
                imageUri: imageUri,
                habit: habit
            )
            modelContext.insert(newEntry)
        }

        try modelContext.save()
        return stalePhotoURIs
    }

    @discardableResult
    static func deleteEntries(
        habit: Habit,
        dateString: String,
        in modelContext: ModelContext
    ) throws -> [String] {
        let entries = try entries(for: habit, dateString: dateString, in: modelContext)
        let photoURIs = uniquePhotoURIs(from: entries)

        for entry in entries {
            modelContext.delete(entry)
        }

        try modelContext.save()
        return photoURIs
    }

    private static func entries(
        for habit: Habit,
        dateString: String,
        in modelContext: ModelContext
    ) throws -> [HabitEntry] {
        let habitId = habit.id
        let predicate = #Predicate<HabitEntry> { entry in
            entry.dateString == dateString && entry.habit?.id == habitId
        }
        let descriptor = FetchDescriptor<HabitEntry>(predicate: predicate)
        return try modelContext.fetch(descriptor)
    }

    private static func deleteDuplicates(
        in entries: [HabitEntry],
        keeping keeper: HabitEntry,
        in modelContext: ModelContext
    ) {
        for duplicate in entries where duplicate !== keeper {
            modelContext.delete(duplicate)
        }
    }

    private static func uniquePhotoURIs(from entries: [HabitEntry], excluding keptURI: String? = nil) -> [String] {
        var seen = Set<String>()
        var result: [String] = []

        for entry in entries {
            guard let uri = entry.imageUri, uri != keptURI, !seen.contains(uri) else { continue }
            seen.insert(uri)
            result.append(uri)
        }

        return result
    }
}
