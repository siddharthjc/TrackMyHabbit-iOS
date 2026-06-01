import Foundation
import Testing
@testable import TrackMyHabbit

struct TrackMyHabbitTests {

    @Test func persistJPEGUsesUniqueFileNamesForRepeatedSaves() throws {
        let habitID = UUID()
        let dateString = "2026-04-11"
        let firstURL = try HabitPhotoFileStore.persistJPEG(
            data: Data("first image".utf8),
            habitID: habitID,
            dateString: dateString
        )
        let secondURL = try HabitPhotoFileStore.persistJPEG(
            data: Data("second image".utf8),
            habitID: habitID,
            dateString: dateString
        )
        defer {
            try? FileManager.default.removeItem(at: firstURL)
            try? FileManager.default.removeItem(at: secondURL)
        }

        #expect(firstURL != secondURL)
        #expect(firstURL.lastPathComponent.hasPrefix("\(dateString)-"))
        #expect(secondURL.lastPathComponent.hasPrefix("\(dateString)-"))
        #expect(FileManager.default.fileExists(atPath: firstURL.path))
        #expect(FileManager.default.fileExists(atPath: secondURL.path))
    }

    @Test func habitEntryLookupPrefersPhotoBackedDuplicate() {
        let missingPhoto = HabitEntry(dateString: "2026-04-11")
        let photoEntry = HabitEntry(dateString: "2026-04-11", imageUri: "file:///photo.jpg")
        let habit = Habit(name: "Read", frequency: "Daily", entries: [missingPhoto, photoEntry])

        #expect(habit.entry(for: "2026-04-11") === photoEntry)
    }

    @Test func photoEntriesByDateIgnoresMissingPhotosAndKeepsFirstDuplicate() {
        let firstPhoto = HabitEntry(dateString: "2026-04-11", imageUri: "file:///first.jpg")
        let duplicatePhoto = HabitEntry(dateString: "2026-04-11", imageUri: "file:///duplicate.jpg")
        let missingPhoto = HabitEntry(dateString: "2026-04-12")

        let entriesByDate = HabitEntry.photoEntriesByDate([
            firstPhoto,
            duplicatePhoto,
            missingPhoto
        ])

        #expect(entriesByDate.count == 1)
        #expect(entriesByDate["2026-04-11"] === firstPhoto)
        #expect(entriesByDate["2026-04-12"] == nil)
    }

}
