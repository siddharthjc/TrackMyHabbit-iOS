import Foundation

struct DateUtils {
    
    /// Returns a date string in YYYY-MM-DD format for a given Date object.
    static func toDateString(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
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
        let calendar = Calendar.current
        
        for i in 0..<count {
            if let date = calendar.date(byAdding: .day, value: -i, to: now) {
                days.append(toDateString(date: date))
            }
        }
        return days
    }
    
    /// Formats a YYYY-MM-DD date string to "4 March" style.
    static func formatDate(_ dateStr: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let date = formatter.date(from: dateStr) else { return dateStr }
        
        let displayFormatter = DateFormatter()
        displayFormatter.dateFormat = "d MMMM"
        return displayFormatter.string(from: date)
    }
    
    /// Returns a relative label: "Today", "Yesterday", or the day-of-week name.
    static func getRelativeLabel(_ dateStr: String) -> String {
        let today = getTodayString()
        if dateStr == today { return "Today" }
        
        let calendar = Calendar.current
        if let yesterdayDate = calendar.date(byAdding: .day, value: -1, to: Date()),
           dateStr == toDateString(date: yesterdayDate) {
            return "Yesterday"
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let date = formatter.date(from: dateStr) else { return "" }
        
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "EEEE" // Full day name
        return dayFormatter.string(from: date)
    }
}
