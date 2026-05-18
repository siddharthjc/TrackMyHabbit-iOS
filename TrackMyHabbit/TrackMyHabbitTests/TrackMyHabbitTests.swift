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

    @Test func persistJPEGCreatesUniqueFilesForSameHabitAndDate() throws {
        let habitID = UUID()
        let dateString = "2026-04-11"
        let fileManager = FileManager.default
        let appSupportURL = try fileManager.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        let photoDirectory = appSupportURL
            .appendingPathComponent("HabitPhotos", isDirectory: true)
            .appendingPathComponent(habitID.uuidString, isDirectory: true)

        try? fileManager.removeItem(at: photoDirectory)
        defer {
            try? fileManager.removeItem(at: photoDirectory)
        }

        let firstData = Data("first-photo".utf8)
        let secondData = Data("second-photo".utf8)

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
        #expect(fileManager.fileExists(atPath: firstURL.path))
        #expect(fileManager.fileExists(atPath: secondURL.path))
        #expect(try Data(contentsOf: firstURL) == firstData)
        #expect(try Data(contentsOf: secondURL) == secondData)
    }

}
