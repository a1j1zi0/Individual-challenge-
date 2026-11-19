import SwiftUI

struct DayCell: View {
    let day: DayItem

    private var accent: Color? {
        switch day.status {
        case .learned: return Color.appOrange
        case .freezed: return Color.appBlue
        case nil: return nil
        }
    }

    var body: some View {
        Text("\(day.number)")
            .font(.subheadline.weight(.medium))
            .frame(width: 36, height: 36)
            // رقم اليوم الحالي صار أبيض فوق الدائرة البرتقالية (كان أسود) مثل التصميم
            .foregroundStyle(accent ?? Color.white)
            .background(Circle().fill(accent?.opacity(0.25) ?? (day.isToday ? Color.appOrange : Color.clear)))
    }
}
