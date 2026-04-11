import Foundation
import SwiftData

@Model
final class Habit {
    @Attribute(.unique)
    var id: UUID
    var name: String
    var frequency: String
    var createdAt: Date
    
    @Relationship(deleteRule: .cascade, inverse: \HabitEntry.habit)
    var entries: [HabitEntry]
    
    init(
        id: UUID = UUID(),
        name: String,
        frequency: String,
        createdAt: Date = Date(),
        entries: [HabitEntry] = []
    ) {
        self.id = id
        self.name = name
        self.frequency = frequency
        self.createdAt = createdAt
        self.entries = entries
    }
}

@Model
final class HabitEntry {
    @Attribute(.unique)
    var id: UUID
    
    var dateString: String // Format: YYYY-MM-DD
    var imageUri: String?
    
    var habit: Habit?
    
    init(id: UUID = UUID(), dateString: String, imageUri: String? = nil, habit: Habit? = nil) {
        self.id = id
        self.dateString = dateString
        self.imageUri = imageUri
        self.habit = habit
    }
}
