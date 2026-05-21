import Foundation
import SwiftData

enum HabitEntryStore {
    static func entries(for habit: Habit, dateString: String, in modelContext: ModelContext) -> [HabitEntry] {
        do {
            let habitID = habit.id
            let predicate = #Predicate<HabitEntry> { entry in
                entry.dateString == dateString && entry.habit?.id == habitID
            }
            let descriptor = FetchDescriptor<HabitEntry>(predicate: predicate)
            let results = try modelContext.fetch(descriptor)
            if !results.isEmpty {
                return results
            }
        } catch {
            // Fall back to the relationship snapshot so callers can still act
            // if SwiftData cannot service the fetch.
        }

        return habit.entries.filter { $0.dateString == dateString }
    }

    static func preferredEntry(from entries: [HabitEntry]) -> HabitEntry? {
        entries.first(where: { $0.imageUri != nil }) ?? entries.first
    }

    static func fileURLs(from entries: [HabitEntry]) -> [URL] {
        var urls: [URL] = []
        for entry in entries {
            guard let uri = entry.imageUri,
                  let url = URL(string: uri),
                  !urls.contains(url) else {
                continue
            }
            urls.append(url)
        }
        return urls
    }

    static func removeFiles(at urls: [URL]) {
        for url in urls {
            try? FileManager.default.removeItem(at: url)
        }
    }
}
