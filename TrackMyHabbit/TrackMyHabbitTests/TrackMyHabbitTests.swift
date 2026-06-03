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

    @Test func persistJPEGCreatesUniqueFilesForSameHabitDate() throws {
        let habitID = UUID()
        defer { removePhotoDirectory(for: habitID) }

        let firstURL = try HabitPhotoFileStore.persistJPEG(
            data: Data([0x01]),
            habitID: habitID,
            dateString: "2026-04-11"
        )
        let secondURL = try HabitPhotoFileStore.persistJPEG(
            data: Data([0x02]),
            habitID: habitID,
            dateString: "2026-04-11"
        )

        #expect(firstURL != secondURL)
        #expect(firstURL.lastPathComponent.hasPrefix("2026-04-11-"))
        #expect(secondURL.lastPathComponent.hasPrefix("2026-04-11-"))
        #expect(FileManager.default.fileExists(atPath: firstURL.path))
        #expect(FileManager.default.fileExists(atPath: secondURL.path))
    }

    @MainActor
    @Test func savePhotoCollapsesDuplicateEntriesAndRemovesOldFiles() throws {
        let container = try makeTestContainer()
        let context = container.mainContext
        let habit = Habit(name: "Morning jog", frequency: "Daily")
        let dateString = "2026-04-11"
        defer { removePhotoDirectory(for: habit.id) }

        let firstURL = try HabitPhotoFileStore.persistJPEG(data: Data([0x01]), habitID: habit.id, dateString: dateString)
        let duplicateURL = try HabitPhotoFileStore.persistJPEG(data: Data([0x02]), habitID: habit.id, dateString: dateString)
        context.insert(habit)
        context.insert(HabitEntry(dateString: dateString, imageUri: firstURL.absoluteString, habit: habit))
        context.insert(HabitEntry(dateString: dateString, imageUri: duplicateURL.absoluteString, habit: habit))
        try context.save()

        let replacementURL = try HabitEntryStore.savePhoto(
            data: Data([0x03]),
            habit: habit,
            dateString: dateString,
            modelContext: context
        )
        let entries = try fetchEntries(in: context, habit: habit, dateString: dateString)

        #expect(entries.count == 1)
        #expect(entries.first?.imageUri == replacementURL.absoluteString)
        #expect(FileManager.default.fileExists(atPath: replacementURL.path))
        #expect(!FileManager.default.fileExists(atPath: firstURL.path))
        #expect(!FileManager.default.fileExists(atPath: duplicateURL.path))
    }

    @MainActor
    @Test func deleteEntriesRemovesAllDuplicateRowsAndFiles() throws {
        let container = try makeTestContainer()
        let context = container.mainContext
        let habit = Habit(name: "Read", frequency: "Daily")
        let dateString = "2026-04-12"
        defer { removePhotoDirectory(for: habit.id) }

        let firstURL = try HabitPhotoFileStore.persistJPEG(data: Data([0x04]), habitID: habit.id, dateString: dateString)
        let duplicateURL = try HabitPhotoFileStore.persistJPEG(data: Data([0x05]), habitID: habit.id, dateString: dateString)
        context.insert(habit)
        context.insert(HabitEntry(dateString: dateString, imageUri: firstURL.absoluteString, habit: habit))
        context.insert(HabitEntry(dateString: dateString, imageUri: duplicateURL.absoluteString, habit: habit))
        try context.save()

        try HabitEntryStore.deleteEntries(for: habit, dateString: dateString, modelContext: context)
        let entries = try fetchEntries(in: context, habit: habit, dateString: dateString)

        #expect(entries.isEmpty)
        #expect(!FileManager.default.fileExists(atPath: firstURL.path))
        #expect(!FileManager.default.fileExists(atPath: duplicateURL.path))
    }

    @MainActor
    private func makeTestContainer() throws -> ModelContainer {
        let schema = Schema([Habit.self, HabitEntry.self])
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        return try ModelContainer(for: schema, configurations: configuration)
    }

    @MainActor
    private func fetchEntries(in context: ModelContext, habit: Habit, dateString: String) throws -> [HabitEntry] {
        let habitID = habit.id
        let predicate = #Predicate<HabitEntry> { entry in
            entry.dateString == dateString && entry.habit?.id == habitID
        }
        let descriptor = FetchDescriptor<HabitEntry>(predicate: predicate)
        return try context.fetch(descriptor)
    }

    private func removePhotoDirectory(for habitID: UUID) {
        guard let appSupportURL = try? FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false
        ) else { return }

        let photoDirectory = appSupportURL
            .appendingPathComponent("HabitPhotos", isDirectory: true)
            .appendingPathComponent(habitID.uuidString, isDirectory: true)
        try? FileManager.default.removeItem(at: photoDirectory)
    }
}
