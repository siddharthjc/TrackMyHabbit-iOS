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

    @Test func persistingPhotoForSameHabitAndDateKeepsPreviousFile() throws {
        let habitID = UUID()
        let dateString = "2026-04-11"
        let firstData = Data("first photo".utf8)
        let replacementData = Data("replacement photo".utf8)

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
        #expect(try Data(contentsOf: firstURL) == firstData)
        #expect(try Data(contentsOf: replacementURL) == replacementData)
    }

}
