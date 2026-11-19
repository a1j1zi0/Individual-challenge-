import SwiftUI

struct WeekStripView: View {
    let days: [DayItem]

    var body: some View {
        HStack {
            ForEach(days) { day in
                VStack(spacing: 6) {
                    Text(day.letter)
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.secondary)
                    DayCell(day: day)
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
}
