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

    @Test func persistingPhotoForSameDatePreservesExistingFile() throws {
        let habitID = UUID()
        let dateString = "2026-04-11"
        let firstData = Data("first photo".utf8)
        let secondData = Data("second photo".utf8)

        let firstURL = try HabitPhotoFileStore.persistJPEG(
            data: firstData,
            habitID: habitID,
            dateString: dateString
        )
        let secondURL = try HabitPhotoFileStore.persistJPEG(
            data: secondData,
            habitID: habitID,
            dateString: dateString
        )

        defer {
            HabitPhotoFileStore.removeFile(at: firstURL.absoluteString)
            HabitPhotoFileStore.removeFile(at: secondURL.absoluteString)
        }

        let storedFirstData = try Data(contentsOf: firstURL)
        let storedSecondData = try Data(contentsOf: secondURL)

        #expect(firstURL != secondURL)
        #expect(storedFirstData == firstData)
        #expect(storedSecondData == secondData)
    }

}
