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

    /// Re-fetches a habit by stable ID so async photo callbacks can avoid
    /// touching a SwiftData instance invalidated by a concurrent delete.
    static func fetch(id: UUID, in modelContext: ModelContext) -> Habit? {
        let habitID = id
        let predicate = #Predicate<Habit> { habit in
            habit.id == habitID
        }
        let descriptor = FetchDescriptor<Habit>(predicate: predicate)
        return try? modelContext.fetch(descriptor).first
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
}
