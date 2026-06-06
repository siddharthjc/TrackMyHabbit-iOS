//
//  TrackMyHabbitTests.swift
//  TrackMyHabbitTests
//
//  Created by Siddharth Chhatpar on 16/03/26.
//

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

    @Test func preferredEntryUsesPhotoBearingDuplicate() {
        let emptyEntry = HabitEntry(dateString: "2026-04-11")
        let photoEntry = HabitEntry(dateString: "2026-04-11", imageUri: "file:///photo.jpg")
        let otherDayPhoto = HabitEntry(dateString: "2026-04-12", imageUri: "file:///other.jpg")

        let preferred = HabitEntry.preferredEntry(for: "2026-04-11", in: [
            emptyEntry,
            photoEntry,
            otherDayPhoto
        ])

        #expect(preferred === photoEntry)
    }

    @Test func photoEntriesByDateUsesPhotoBearingDuplicateWhenEmptyEntryComesFirst() {
        let emptyEntry = HabitEntry(dateString: "2026-04-11")
        let photoEntry = HabitEntry(dateString: "2026-04-11", imageUri: "file:///photo.jpg")

        let entriesByDate = HabitEntry.photoEntriesByDate([
            emptyEntry,
            photoEntry
        ])

        #expect(entriesByDate["2026-04-11"] === photoEntry)
    }

}
