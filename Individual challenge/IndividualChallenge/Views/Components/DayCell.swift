import SwiftUI

struct DayCell: View {
    let day: DayItem
    // حجم الدائرة يكبر مع حجم الخط اللي يختاره المستخدم (Dynamic Type) بدل 36 ثابت
    @ScaledMetric(relativeTo: .subheadline) private var size: CGFloat = 36

    private var accent: Color? {
        switch day.status {
        case .learned: return Color.appOrange
        case .freezed: return Color.appBlue
        case nil: return nil
        }
    }

    var body: some View {
        // verbatim: الرقم ما يحتاج ترجمة، فما ينضاف للـ String Catalog
        Text(verbatim: "\(day.number)")
            .font(.subheadline.weight(.medium))
            .frame(width: size, height: size)
            // رقم اليوم الحالي صار أبيض فوق الدائرة البرتقالية (كان أسود) مثل التصميم
            .foregroundStyle(accent ?? Color.white)
            .background(Circle().fill(accent?.opacity(0.25) ?? (day.isToday ? Color.appOrange : Color.clear)))
            // VoiceOver يقرأ التاريخ كامل مع حالته ("..., Learned, Today") بدل الرقم بس،
            // عشان حالة اليوم ما تكون معروفة باللون بس
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(day.accessibilityLabel)
    }
}
