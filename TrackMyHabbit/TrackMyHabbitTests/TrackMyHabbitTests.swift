//
//  TrackMyHabbitTests.swift
//  TrackMyHabbitTests
//
//  Created by Siddharth Chhatpar on 16/03/26.
//

import Testing
import Foundation
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

    @Test func photoPersistenceUsesUniquePathsForReplacementAttempts() throws {
        let habitID = UUID()
        let dateString = "2026-04-11"
        let firstData = Data([0x01, 0x02, 0x03])
        let replacementData = Data([0x04, 0x05, 0x06])

        let firstURL = try HabitPhotoFileStore.persistJPEG(
            data: firstData,
            habitID: habitID,
            dateString: dateString
        )
        defer { try? FileManager.default.removeItem(at: firstURL.deletingLastPathComponent()) }

        let replacementURL = try HabitPhotoFileStore.persistJPEG(
            data: replacementData,
            habitID: habitID,
            dateString: dateString
        )

        #expect(firstURL != replacementURL)
        #expect(FileManager.default.fileExists(atPath: firstURL.path))
        #expect(try Data(contentsOf: firstURL) == firstData)
        #expect(try Data(contentsOf: replacementURL) == replacementData)
    }

}
