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

    @Test func photoTransactionRollbackRestoresExistingPhoto() throws {
        let habitID = UUID()
        let dateString = "2099-01-01"
        let originalData = Data("original".utf8)
        let replacementData = Data("replacement".utf8)

        let originalURL = try HabitPhotoFileStore.persistJPEG(
            data: originalData,
            habitID: habitID,
            dateString: dateString
        )
        defer { try? FileManager.default.removeItem(at: originalURL.deletingLastPathComponent()) }

        let persistedPhoto = try HabitPhotoFileStore.persistJPEGTransaction(
            data: replacementData,
            habitID: habitID,
            dateString: dateString
        )

        let writtenData = try Data(contentsOf: persistedPhoto.fileURL)
        #expect(writtenData == replacementData)

        persistedPhoto.rollback()

        let restoredData = try Data(contentsOf: originalURL)
        #expect(restoredData == originalData)
    }

    @Test func photoTransactionRollbackRemovesNewPhotoWhenNoBackupExists() throws {
        let habitID = UUID()
        let dateString = "2099-01-02"
        let photoData = Data("new".utf8)

        let persistedPhoto = try HabitPhotoFileStore.persistJPEGTransaction(
            data: photoData,
            habitID: habitID,
            dateString: dateString
        )
        defer { try? FileManager.default.removeItem(at: persistedPhoto.fileURL.deletingLastPathComponent()) }

        #expect(FileManager.default.fileExists(atPath: persistedPhoto.fileURL.path))

        persistedPhoto.rollback()

        #expect(!FileManager.default.fileExists(atPath: persistedPhoto.fileURL.path))
    }

}
