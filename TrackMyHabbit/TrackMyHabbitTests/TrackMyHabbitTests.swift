//
//  TrackMyHabbitTests.swift
//  TrackMyHabbitTests
//
//  Created by Siddharth Chhatpar on 16/03/26.
//

import Foundation
import Testing
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

    @Test func persistJPEGCreatesUniqueFilesForSameHabitAndDate() throws {
        let habitID = UUID()
        let dateString = "2026-04-11"
        let firstData = Data("first photo".utf8)
        let secondData = Data("second photo".utf8)

        let firstURL = try HabitPhotoFileStore.persistJPEG(
            data: firstData,
            habitID: habitID,
            dateString: dateString
        )
        let photoDirectory = firstURL.deletingLastPathComponent()
        defer {
            try? FileManager.default.removeItem(at: photoDirectory)
        }

        let secondURL = try HabitPhotoFileStore.persistJPEG(
            data: secondData,
            habitID: habitID,
            dateString: dateString
        )
        let persistedFirstData = try Data(contentsOf: firstURL)
        let persistedSecondData = try Data(contentsOf: secondURL)

        #expect(firstURL != secondURL)
        #expect(firstURL.lastPathComponent.hasPrefix("\(dateString)-"))
        #expect(secondURL.lastPathComponent.hasPrefix("\(dateString)-"))
        #expect(persistedFirstData == firstData)
        #expect(persistedSecondData == secondData)
    }

    @Test func isFutureDateStringDetectsDaysAfterToday() throws {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = try #require(TimeZone(secondsFromGMT: 0))
        let today = try #require(
            calendar.date(from: DateComponents(year: 2026, month: 7, day: 24, hour: 15))
        )
        let tomorrow = try #require(calendar.date(byAdding: .day, value: 1, to: today))
        let yesterday = try #require(calendar.date(byAdding: .day, value: -1, to: today))

        #expect(DateUtils.isFutureDateString(DateUtils.toDateString(date: tomorrow), today: today))
        #expect(!DateUtils.isFutureDateString(DateUtils.toDateString(date: today), today: today))
        #expect(!DateUtils.isFutureDateString(DateUtils.toDateString(date: yesterday), today: today))
    }

    @Test func deleteAllPhotosRemovesHabitPhotoDirectory() throws {
        let habitID = UUID()
        let fileURL = try HabitPhotoFileStore.persistJPEG(
            data: Data("habit photo".utf8),
            habitID: habitID,
            dateString: "2026-07-24"
        )
        let photoDirectory = fileURL.deletingLastPathComponent()
        #expect(FileManager.default.fileExists(atPath: photoDirectory.path))

        try HabitPhotoFileStore.deleteAllPhotos(for: habitID)

        #expect(!FileManager.default.fileExists(atPath: photoDirectory.path))
    }

    @Test func rollbackRestoresPendingHabitDeletion() throws {
        let container = try ModelContainer(
            for: Habit.self,
            HabitEntry.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let modelContext = ModelContext(container)
        let habit = Habit(name: "Read", frequency: "Daily")
        modelContext.insert(habit)
        try modelContext.save()

        modelContext.delete(habit)
        modelContext.rollback()

        let habits = try modelContext.fetch(FetchDescriptor<Habit>())
        #expect(habits.count == 1)
        #expect(habits.first?.name == "Read")
    }

    @Test func rollbackRestoresPhotoMutationAndPendingDuplicateDeletion() throws {
        let container = try ModelContainer(
            for: Habit.self,
            HabitEntry.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let modelContext = ModelContext(container)
        let habit = Habit(name: "Read", frequency: "Daily")
        let retainedEntry = HabitEntry(
            dateString: "2026-04-11",
            imageUri: "file:///committed.jpg",
            habit: habit
        )
        let duplicateEntry = HabitEntry(dateString: "2026-04-11", habit: habit)

        modelContext.insert(habit)
        modelContext.insert(retainedEntry)
        modelContext.insert(duplicateEntry)
        try modelContext.save()

        retainedEntry.imageUri = "file:///failed-attempt.jpg"
        modelContext.delete(duplicateEntry)
        modelContext.rollback()

        let restoredEntries = try HabitEntry.entries(
            for: habit,
            dateString: "2026-04-11",
            in: modelContext
        )

        #expect(restoredEntries.count == 2)
        #expect(restoredEntries.contains { $0.imageUri == "file:///committed.jpg" })
    }

}
