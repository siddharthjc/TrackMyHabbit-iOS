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

    @Test func preferredEntryChoosesPhotoBackedDuplicate() {
        let blankDuplicate = HabitEntry(dateString: "2026-04-11")
        let photoDuplicate = HabitEntry(dateString: "2026-04-11", imageUri: "file:///photo.jpg")

        let preferred = HabitEntryStore.preferredEntry(in: [
            blankDuplicate,
            photoDuplicate
        ], dateString: "2026-04-11")

        #expect(preferred === photoDuplicate)
    }

    @Test func photoFileStoreCreatesUniqueFilesForRepeatedDateSaves() throws {
        let habitID = UUID()
        let dateString = "2026-04-11"
        let firstURL = try HabitPhotoFileStore.persistJPEG(
            data: Data("first".utf8),
            habitID: habitID,
            dateString: dateString
        )
        let secondURL = try HabitPhotoFileStore.persistJPEG(
            data: Data("second".utf8),
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

}
