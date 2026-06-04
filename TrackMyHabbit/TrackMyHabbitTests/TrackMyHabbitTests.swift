//
//  TrackMyHabbitTests.swift
//  TrackMyHabbitTests
//
//  Created by Siddharth Chhatpar on 16/03/26.
//

import Foundation
import Testing
@testable import TrackMyHabbit

struct TrackMyHabbitTests {

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

    @Test func preferredEntryKeepsPhotoBackedDuplicate() {
        let missingPhoto = HabitEntry(dateString: "2026-04-11")
        let photoEntry = HabitEntry(dateString: "2026-04-11", imageUri: "file:///photo.jpg")

        let preferred = HabitEntryStore.preferredEntry(in: [missingPhoto, photoEntry])

        #expect(preferred === photoEntry)
    }

    @Test func duplicateEntriesExcludePreferredEntry() {
        let preferred = HabitEntry(dateString: "2026-04-11", imageUri: "file:///photo.jpg")
        let duplicate = HabitEntry(dateString: "2026-04-11")

        let duplicates = HabitEntryStore.duplicateEntries(in: [preferred, duplicate], keeping: preferred)

        #expect(duplicates.count == 1)
        #expect(duplicates.first === duplicate)
    }

    @Test func photoFileStoreCreatesUniqueAttemptFilenames() throws {
        let habitID = UUID()
        let dateString = "2026-04-11"
        let firstURL = try HabitPhotoFileStore.persistJPEG(
            data: Data("first".utf8),
            habitID: habitID,
            dateString: dateString
        )
        defer { try? FileManager.default.removeItem(at: firstURL.deletingLastPathComponent()) }

        let secondURL = try HabitPhotoFileStore.persistJPEG(
            data: Data("second".utf8),
            habitID: habitID,
            dateString: dateString
        )

        #expect(firstURL != secondURL)
        #expect(firstURL.lastPathComponent.hasPrefix("\(dateString)-"))
        #expect(secondURL.lastPathComponent.hasPrefix("\(dateString)-"))
    }

}
