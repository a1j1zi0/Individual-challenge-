import SwiftUI

struct MonthView: View {
    let section: MonthSection
    let weekdayHeaders: [String]       // جديد: SUN MON TUE ... تجي من الـ ViewModel
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(section.title)
                .font(.subheadline.weight(.semibold))   // أصغر من .headline مثل التصميم

            LazyVGrid(columns: columns, spacing: 8) {
                // صف أسماء الأيام فوق كل شهر مثل التصميم
                ForEach(weekdayHeaders, id: \.self) { name in
                    Text(name)
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
                ForEach(0..<section.blanks, id: \.self) { _ in
                    Color.clear.frame(height: 36)
                }
                ForEach(section.days) { day in
                    DayCell(day: day)
                }
            }
        }
    }
}
