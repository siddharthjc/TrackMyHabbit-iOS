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

    @Test func displayPhotoEntryPrefersPhotoOverEmptyDuplicate() {
        let emptyEntry = HabitEntry(dateString: "2026-04-11")
        let photoEntry = HabitEntry(dateString: "2026-04-11", imageUri: "file:///photo.jpg")

        let entry = HabitEntryPersistence.photoEntry(
            from: [emptyEntry, photoEntry],
            dateString: "2026-04-11"
        )

        #expect(entry === photoEntry)
    }

    @Test func photoStoreUsesUniqueFilenamesForRepeatedSaves() throws {
        let habitID = UUID()
        let dateString = "2026-04-11"
        let data = Data([0x01, 0x02, 0x03])
        var writtenURLs: [URL] = []
        defer {
            for url in writtenURLs {
                try? FileManager.default.removeItem(at: url)
            }
            if let photoDirectory = writtenURLs.first?.deletingLastPathComponent() {
                try? FileManager.default.removeItem(at: photoDirectory)
            }
        }

        let firstURL = try HabitPhotoFileStore.persistJPEG(
            data: data,
            habitID: habitID,
            dateString: dateString
        )
        writtenURLs.append(firstURL)
        let secondURL = try HabitPhotoFileStore.persistJPEG(
            data: data,
            habitID: habitID,
            dateString: dateString
        )
        writtenURLs.append(secondURL)

        #expect(firstURL != secondURL)
        #expect(firstURL.lastPathComponent.hasPrefix("\(dateString)-"))
        #expect(secondURL.lastPathComponent.hasPrefix("\(dateString)-"))
        #expect(FileManager.default.fileExists(atPath: firstURL.path))
        #expect(FileManager.default.fileExists(atPath: secondURL.path))
    }
}
