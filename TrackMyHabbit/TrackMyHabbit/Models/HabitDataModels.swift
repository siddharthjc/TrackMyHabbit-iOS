import Foundation
import SwiftData

@Model
final class Habit {
    @Attribute(.unique)
    var id: UUID
    var name: String
    var frequency: String
    var createdAt: Date
    
    @Relationship(deleteRule: .cascade, inverse: \HabitEntry.habit)
    var entries: [HabitEntry]
    
    init(
        id: UUID = UUID(),
        name: String,
        frequency: String,
        createdAt: Date = Date(),
        entries: [HabitEntry] = []
    ) {
        self.id = id
        self.name = name
        self.frequency = frequency
        self.createdAt = createdAt
        self.entries = entries
    }
}

@Model
final class HabitEntry {
    @Attribute(.unique)
    var id: UUID
    
    var dateString: String // Format: YYYY-MM-DD
    var imageUri: String?
    
    var habit: Habit?
    
    init(id: UUID = UUID(), dateString: String, imageUri: String? = nil, habit: Habit? = nil) {
        self.id = id
        self.dateString = dateString
        self.imageUri = imageUri
        self.habit = habit
    }
}

extension Habit {
    func photoEntriesByDate() -> [String: HabitEntry] {
        entries.reduce(into: [:]) { result, entry in
            guard entry.imageUri != nil, result[entry.dateString] == nil else { return }
            result[entry.dateString] = entry
        }
    }
}

extension HabitEntry {
    static func photoEntriesByDate(_ entries: [HabitEntry]) -> [String: HabitEntry] {
        entries.reduce(into: [:]) { result, entry in
            guard entry.imageUri != nil else { return }
            result[entry.dateString] = result[entry.dateString] ?? entry
        }
    }

    static func entries(for habit: Habit, dateString: String, in modelContext: ModelContext) throws -> [HabitEntry] {
        let habitId = habit.id
        let predicate = #Predicate<HabitEntry> { entry in
            entry.dateString == dateString && entry.habit?.id == habitId
        }
        let descriptor = FetchDescriptor<HabitEntry>(predicate: predicate)
        return try modelContext.fetch(descriptor)
    }

    static func entries(for dateString: String, in entries: [HabitEntry]) -> [HabitEntry] {
        entries.filter { $0.dateString == dateString }
    }

    static func preferredEntry(for dateString: String, in entries: [HabitEntry]) -> HabitEntry? {
        preferredEntry(in: Self.entries(for: dateString, in: entries))
    }

    static func preferredEntry(in entries: [HabitEntry]) -> HabitEntry? {
        entries.first(where: { $0.imageUri != nil }) ?? entries.first
    }

    static func deleteDuplicates(in entries: [HabitEntry], keeping retainedEntry: HabitEntry, from modelContext: ModelContext) {
        for entry in entries where entry !== retainedEntry {
            modelContext.delete(entry)
        }
    }

    static func savePhoto(data: Data, for habit: Habit, dateString: String, in modelContext: ModelContext) throws {
        let fileURL = try HabitPhotoFileStore.persistJPEG(
            data: data,
            habitID: habit.id,
            dateString: dateString
        )
        let matchingEntries = entriesForSave(for: habit, dateString: dateString, in: modelContext)
        let existing = preferredEntry(in: matchingEntries)
        let fileWasAlreadyReferenced = matchingEntries.contains { $0.imageUri == fileURL.absoluteString }
        let supersededPhotoURLs = Set(matchingEntries.compactMap { entry -> URL? in
            guard let uri = entry.imageUri, uri != fileURL.absoluteString else { return nil }
            return URL(string: uri)
        })

        do {
            if let existing {
                existing.imageUri = fileURL.absoluteString
                deleteDuplicates(in: matchingEntries, keeping: existing, from: modelContext)
            } else {
                let newEntry = HabitEntry(
                    dateString: dateString,
                    imageUri: fileURL.absoluteString,
                    habit: habit
                )
                modelContext.insert(newEntry)
            }
            try modelContext.save()
            for url in supersededPhotoURLs {
                try? FileManager.default.removeItem(at: url)
            }
        } catch {
            if !fileWasAlreadyReferenced {
                try? FileManager.default.removeItem(at: fileURL)
            }
            throw error
        }
    }

    static func resolvedEntry(for habit: Habit, dateString: String, in modelContext: ModelContext) -> HabitEntry? {
        do {
            let matchingEntries = try entries(for: habit, dateString: dateString, in: modelContext)
            guard let retainedEntry = preferredEntry(in: matchingEntries) else { return nil }
            if matchingEntries.count > 1 {
                deleteDuplicates(in: matchingEntries, keeping: retainedEntry, from: modelContext)
                try? modelContext.save()
            }
            return retainedEntry
        } catch {
            return preferredEntry(for: dateString, in: habit.entries)
        }
    }

    private static func entriesForSave(for habit: Habit, dateString: String, in modelContext: ModelContext) -> [HabitEntry] {
        do {
            return try entries(for: habit, dateString: dateString, in: modelContext)
        } catch {
            return entries(for: dateString, in: habit.entries)
        }
    }
}
