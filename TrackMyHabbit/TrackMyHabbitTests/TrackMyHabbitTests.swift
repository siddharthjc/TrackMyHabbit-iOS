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

    @Test func preferredEntryChoosesPhotoWhenDuplicateWithoutPhotoIsFirst() {
        let missingPhoto = HabitEntry(dateString: "2026-04-11")
        let photo = HabitEntry(dateString: "2026-04-11", imageUri: "file:///photo.jpg")

        let preferred = HabitEntryStore.preferredEntry(from: [missingPhoto, photo])

        #expect(preferred === photo)
    }

    @Test func photoFileStoreCreatesUniqueFilesForSameHabitDate() throws {
        let habitID = UUID()
        let data = Data([0x01, 0x02, 0x03])

        let firstURL = try HabitPhotoFileStore.persistJPEG(
            data: data,
            habitID: habitID,
            dateString: "2026-04-11"
        )
        defer {
            try? FileManager.default.removeItem(at: firstURL.deletingLastPathComponent())
        }

        let secondURL = try HabitPhotoFileStore.persistJPEG(
            data: data,
            habitID: habitID,
            dateString: "2026-04-11"
        )

        #expect(firstURL != secondURL)
        #expect(FileManager.default.fileExists(atPath: firstURL.path))
        #expect(FileManager.default.fileExists(atPath: secondURL.path))
    }

}
