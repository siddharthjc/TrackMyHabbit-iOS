//
//  TrackMyHabbitTests.swift
//  TrackMyHabbitTests
//
//  Created by Siddharth Chhatpar on 16/03/26.
//

import Testing
import Foundation
import SwiftData
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

    @MainActor
    @Test func photoPersistenceUsesUniqueFiles() throws {
        let habitID = UUID()
        let firstURL = try HabitPhotoFileStore.persistJPEG(
            data: Data("first".utf8),
            habitID: habitID,
            dateString: "2026-04-11"
        )
        let secondURL = try HabitPhotoFileStore.persistJPEG(
            data: Data("second".utf8),
            habitID: habitID,
            dateString: "2026-04-11"
        )

        defer {
            try? FileManager.default.removeItem(at: firstURL.deletingLastPathComponent())
        }

        #expect(firstURL != secondURL)
        #expect(FileManager.default.fileExists(atPath: firstURL.path))
        #expect(FileManager.default.fileExists(atPath: secondURL.path))
    }

    @MainActor
    @Test func savingPhotoDedupesEntriesAndDeletesOldFilesAfterSave() throws {
        let schema = Schema([Habit.self, HabitEntry.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [configuration])
        let context = container.mainContext
        let dateString = "2026-04-11"
        let habit = Habit(name: "Run", frequency: "Daily")
        let oldURL = try HabitPhotoFileStore.persistJPEG(
            data: Data("old".utf8),
            habitID: habit.id,
            dateString: dateString
        )
        let duplicateURL = try HabitPhotoFileStore.persistJPEG(
            data: Data("duplicate".utf8),
            habitID: habit.id,
            dateString: dateString
        )

        defer {
            try? FileManager.default.removeItem(at: oldURL.deletingLastPathComponent())
        }

        context.insert(habit)
        context.insert(HabitEntry(dateString: dateString, imageUri: oldURL.absoluteString, habit: habit))
        context.insert(HabitEntry(dateString: dateString, imageUri: duplicateURL.absoluteString, habit: habit))
        try context.save()

        try HabitEntryPersistence.savePhoto(
            data: Data("new".utf8),
            habit: habit,
            dateString: dateString,
            in: context
        )

        let habitID = habit.id
        let predicate = #Predicate<HabitEntry> { entry in
            entry.dateString == dateString && entry.habit?.id == habitID
        }
        let entries = try context.fetch(FetchDescriptor<HabitEntry>(predicate: predicate))
        let savedURI = try #require(entries.first?.imageUri)
        let savedURL = try #require(URL(string: savedURI))

        #expect(entries.count == 1)
        #expect(savedURI != oldURL.absoluteString)
        #expect(savedURI != duplicateURL.absoluteString)
        #expect(FileManager.default.fileExists(atPath: oldURL.path) == false)
        #expect(FileManager.default.fileExists(atPath: duplicateURL.path) == false)
        #expect(FileManager.default.fileExists(atPath: savedURL.path))
    }

}
