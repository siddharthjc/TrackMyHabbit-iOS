//
//  TrackMyHabbitTests.swift
//  TrackMyHabbitTests
//
//  Created by Siddharth Chhatpar on 16/03/26.
//

import Foundation
import SwiftData
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

    @Test func preferredEntryUsesPhotoDuplicateWhenFirstEntryIsEmpty() {
        let emptyDuplicate = HabitEntry(dateString: "2026-04-11")
        let photoDuplicate = HabitEntry(dateString: "2026-04-11", imageUri: "file:///photo.jpg")

        let preferred = HabitEntryStore.preferredEntry(from: [emptyDuplicate, photoDuplicate])
        let entriesByDate = HabitEntry.photoEntriesByDate([emptyDuplicate, photoDuplicate])

        #expect(preferred === photoDuplicate)
        #expect(entriesByDate["2026-04-11"] === photoDuplicate)
    }

    @Test func photoFileNameUsesUniqueIdentifierForSameDate() {
        let firstID = UUID(uuidString: "11111111-1111-1111-1111-111111111111")!
        let secondID = UUID(uuidString: "22222222-2222-2222-2222-222222222222")!

        let firstName = HabitPhotoFileStore.photoFileName(dateString: "2026-04-11", fileID: firstID)
        let secondName = HabitPhotoFileStore.photoFileName(dateString: "2026-04-11", fileID: secondID)

        #expect(firstName == "2026-04-11-11111111-1111-1111-1111-111111111111.jpg")
        #expect(secondName == "2026-04-11-22222222-2222-2222-2222-222222222222.jpg")
        #expect(firstName != secondName)
    }

    @MainActor
    @Test func upsertPhotoDeduplicatesRowsAndReportsOldPhotosAfterSave() throws {
        let schema = Schema([Habit.self, HabitEntry.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: configuration)
        let context = container.mainContext
        let habit = Habit(name: "Run", frequency: "Daily")
        let dateString = "2026-04-11"
        let emptyDuplicate = HabitEntry(dateString: dateString, habit: habit)
        let photoDuplicate = HabitEntry(dateString: dateString, imageUri: "file:///old.jpg", habit: habit)

        context.insert(habit)
        context.insert(emptyDuplicate)
        context.insert(photoDuplicate)
        try context.save()

        let stalePhotoURIs = try HabitEntryStore.upsertPhoto(
            habit: habit,
            dateString: dateString,
            imageUri: "file:///new.jpg",
            in: context
        )

        let habitID = habit.id
        let predicate = #Predicate<HabitEntry> { entry in
            entry.dateString == dateString && entry.habit?.id == habitID
        }
        let remainingEntries = try context.fetch(FetchDescriptor<HabitEntry>(predicate: predicate))

        #expect(remainingEntries.count == 1)
        #expect(remainingEntries.first?.imageUri == "file:///new.jpg")
        #expect(stalePhotoURIs == ["file:///old.jpg"])
    }
}
