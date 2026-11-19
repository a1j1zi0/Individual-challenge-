import Foundation

/// تنسيق التواريخ بـ formatters محفوظة (cached).
/// قبل كان ينخلق DateFormatter جديد كل مرة ينعرض تاريخ، وهذا مكلف لأن التقويم يعرض مئات الأيام
enum DateText {
    /// لغة التنسيق نفس لغة التطبيق (الإنجليزي حالياً)، عشان التواريخ ما تطلع بلغة مختلفة عن باقي النصوص
    private static let locale = Locale(identifier: Bundle.main.preferredLocalizations.first ?? "en")

    private static func formatter(_ pattern: String) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.calendar = LearningRules.defaultCalendar
        formatter.locale = locale
        formatter.dateFormat = pattern
        return formatter
    }

    private static let titleFormatter = formatter("EEEE, d MMMM")       // Thursday, 24 October
    private static let letterFormatter = formatter("EEEEE")             // T
    private static let monthFormatter = formatter("MMMM yyyy")          // October 2026
    private static let spokenFormatter = formatter("EEEE, d MMMM yyyy") // لـ VoiceOver

    static func title(_ date: Date) -> String { titleFormatter.string(from: date) }
    static func weekdayLetter(_ date: Date) -> String { letterFormatter.string(from: date) }
    static func month(_ date: Date) -> String { monthFormatter.string(from: date) }
    static func spoken(_ date: Date) -> String { spokenFormatter.string(from: date) }

    /// SUN MON TUE ... فوق كل شهر في التقويم
    static var weekdayHeaders: [String] {
        var calendar = LearningRules.defaultCalendar
        calendar.locale = locale
        return calendar.shortWeekdaySymbols.map { $0.uppercased() }
    }
}
