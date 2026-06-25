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

    @Test func persistJPEGUsesUniqueFilenamesForSameDayWrites() throws {
        let habitID = UUID()
        let firstData = Data([0x01])
        let secondData = Data([0x02])

        let firstURL = try HabitPhotoFileStore.persistJPEG(
            data: firstData,
            habitID: habitID,
            dateString: "2026-04-11"
        )
        let secondURL = try HabitPhotoFileStore.persistJPEG(
            data: secondData,
            habitID: habitID,
            dateString: "2026-04-11"
        )
        defer {
            try? FileManager.default.removeItem(at: firstURL.deletingLastPathComponent())
        }

        #expect(firstURL != secondURL)
        #expect(FileManager.default.contents(atPath: firstURL.path) == firstData)
        #expect(FileManager.default.contents(atPath: secondURL.path) == secondData)
    }

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

    @Test func preferredEntryForDatePrefersPhotoDuplicate() {
        let emptyDuplicate = HabitEntry(dateString: "2026-04-11")
        let photoDuplicate = HabitEntry(dateString: "2026-04-11", imageUri: "file:///photo.jpg")

        let preferredEntry = HabitEntry.preferredEntry(for: "2026-04-11", in: [
            emptyDuplicate,
            photoDuplicate
        ])

        #expect(preferredEntry === photoDuplicate)
    }

    @Test func resolvedEntryRemovesEveryDuplicateAndKeepsPhotoEntry() throws {
        let container = try ModelContainer(
            for: Habit.self,
            HabitEntry.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let modelContext = ModelContext(container)
        let habit = Habit(name: "Read", frequency: "Daily")
        let emptyDuplicate = HabitEntry(dateString: "2026-04-11", habit: habit)
        let photoDuplicate = HabitEntry(dateString: "2026-04-11", imageUri: "file:///photo.jpg", habit: habit)
        let secondEmptyDuplicate = HabitEntry(dateString: "2026-04-11", habit: habit)

        modelContext.insert(habit)
        modelContext.insert(emptyDuplicate)
        modelContext.insert(photoDuplicate)
        modelContext.insert(secondEmptyDuplicate)
        try modelContext.save()

        let retainedEntry = HabitEntry.resolvedEntry(for: habit, dateString: "2026-04-11", in: modelContext)
        let remainingEntries = try HabitEntry.entries(for: habit, dateString: "2026-04-11", in: modelContext)

        #expect(retainedEntry === photoDuplicate)
        #expect(remainingEntries.count == 1)
        #expect(remainingEntries.first?.imageUri == "file:///photo.jpg")
    }

}
