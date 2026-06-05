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

    @Test func preferredEntryUsesPhotoBackedDuplicate() {
        let emptyEntry = HabitEntry(dateString: "2026-04-11")
        let photoEntry = HabitEntry(dateString: "2026-04-11", imageUri: "file:///photo.jpg")

        let preferredEntry = HabitEntry.preferredEntry(from: [emptyEntry, photoEntry])

        #expect(preferredEntry === photoEntry)
    }

    @Test func persistJPEGCreatesUniqueFilesForSameHabitDate() throws {
        let habitID = UUID()
        let dateString = "2026-04-11"
        let firstURL = try HabitPhotoFileStore.persistJPEG(data: Data([0x01]), habitID: habitID, dateString: dateString)
        let secondURL = try HabitPhotoFileStore.persistJPEG(data: Data([0x02]), habitID: habitID, dateString: dateString)

        defer {
            HabitPhotoFileStore.removeFiles(at: [firstURL, secondURL])
        }

        #expect(firstURL != secondURL)
        #expect(firstURL.lastPathComponent.hasPrefix("\(dateString)-"))
        #expect(secondURL.lastPathComponent.hasPrefix("\(dateString)-"))
        #expect(FileManager.default.fileExists(atPath: firstURL.path))
        #expect(FileManager.default.fileExists(atPath: secondURL.path))
    }

}
