import Foundation

struct DateUtils {

    private static var gregorianCalendar: Calendar {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = .current
        cal.locale = .current
        return cal
    }

    private static func dayKeyFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = .current
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }

    private static func parseDayKey(_ dateStr: String) -> Date? {
        dayKeyFormatter().date(from: dateStr)
    }
    
    /// Returns a date string in YYYY-MM-DD format for a given Date object.
    static func toDateString(date: Date) -> String {
        // Use start-of-day so the key is stable across time-of-day.
        let startOfDay = gregorianCalendar.startOfDay(for: date)
        return dayKeyFormatter().string(from: startOfDay)
    }
    
    /// Returns today's date string in YYYY-MM-DD format.
    static func getTodayString() -> String {
        return toDateString(date: Date())
    }
    
    /// Generates an array of date strings going back `count` days from today.
    /// Index 0 = today, index 1 = yesterday, etc.
    static func generateDays(count: Int = 7) -> [String] {
        var days: [String] = []
        let now = Date()
        let calendar = gregorianCalendar
        
        for i in 0..<count {
            if let date = calendar.date(byAdding: .day, value: -i, to: now) {
                days.append(toDateString(date: date))
            }
        }
        return days
    }
    
    /// Formats a YYYY-MM-DD date string to "4 March" style.
    static func formatDate(_ dateStr: String) -> String {
        guard let date = parseDayKey(dateStr) else { return dateStr }
        
        let displayFormatter = DateFormatter()
        displayFormatter.calendar = Calendar(identifier: .gregorian)
        displayFormatter.locale = .current
        displayFormatter.timeZone = .current
        displayFormatter.dateFormat = "d MMMM"
        return displayFormatter.string(from: date)
    }
    
    /// Short weekday label for calendar chips (e.g. "SAT").
    static func weekdayAbbrevUppercased(for date: Date) -> String {
        let dayFormatter = DateFormatter()
        dayFormatter.calendar = Calendar(identifier: .gregorian)
        dayFormatter.locale = .current
        dayFormatter.timeZone = .current
        dayFormatter.dateFormat = "EEE"
        return dayFormatter.string(from: date).uppercased()
    }

    /// Full month name for calendar header (e.g. "April").
    static func monthName(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = .current
        formatter.timeZone = .current
        formatter.dateFormat = "MMMM"
        return formatter.string(from: date)
    }

    /// Returns a relative label: "Today", "Yesterday", or the day-of-week name.
    static func getRelativeLabel(_ dateStr: String) -> String {
        let today = getTodayString()
        if dateStr == today { return "Today" }
        
        let calendar = gregorianCalendar
        if let yesterdayDate = calendar.date(byAdding: .day, value: -1, to: Date()),
           dateStr == toDateString(date: yesterdayDate) {
            return "Yesterday"
        }
        
        guard let date = parseDayKey(dateStr) else { return dateStr }
        
        let dayFormatter = DateFormatter()
        dayFormatter.calendar = Calendar(identifier: .gregorian)
        dayFormatter.locale = .current
        dayFormatter.timeZone = .current
        dayFormatter.dateFormat = "EEEE" // Full day name
        return dayFormatter.string(from: date)
    }
}
