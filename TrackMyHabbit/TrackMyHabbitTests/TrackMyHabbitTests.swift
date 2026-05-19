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

    @Test func photoStoreDoesNotOverwriteSameDayPhotoAttempts() throws {
        let habitID = UUID()
        let dateString = "2026-04-11"
        let firstData = Data([0x01, 0x02, 0x03])
        let secondData = Data([0x04, 0x05, 0x06])

        let appSupportURL = try FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        let photoDirectory = appSupportURL
            .appendingPathComponent("HabitPhotos", isDirectory: true)
            .appendingPathComponent(habitID.uuidString, isDirectory: true)
        try? FileManager.default.removeItem(at: photoDirectory)
        defer { try? FileManager.default.removeItem(at: photoDirectory) }

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

        #expect(firstURL != secondURL)
        let storedFirstData = try Data(contentsOf: firstURL)
        let storedSecondData = try Data(contentsOf: secondURL)
        #expect(storedFirstData == firstData)
        #expect(storedSecondData == secondData)
    }

}
