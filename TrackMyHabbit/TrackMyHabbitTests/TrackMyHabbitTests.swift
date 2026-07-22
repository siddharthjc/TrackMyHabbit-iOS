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

    @Test func walletDaysAdvanceAtDayRollover() throws {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = try #require(TimeZone(secondsFromGMT: 0))
        let beforeRollover = try #require(
            calendar.date(from: DateComponents(year: 2026, month: 7, day: 22, hour: 12))
        )
        let afterRollover = try #require(
            calendar.date(byAdding: .day, value: 1, to: beforeRollover)
        )

        let beforeDays = HabitWalletStack.orderedDateStrings(
            referenceDate: beforeRollover,
            calendar: calendar
        )
        let afterDays = HabitWalletStack.orderedDateStrings(
            referenceDate: afterRollover,
            calendar: calendar
        )

        #expect(beforeDays.dropLast() == afterDays.dropFirst())
        #expect(beforeDays.last != afterDays.last)
    }

}
