import SwiftUI

struct GoalForm: View {
    @Binding var topic: String
    @Binding var duration: GoalDuration

    var body: some View {
        // spacing: 0 عشان كل عنصر ياخذ مسافته الخاصة بـ padding
        VStack(alignment: .leading, spacing: 0) {
            Text("I want to learn")
                .font(.subheadline)       // خط عادي وأصغر بدل .headline العريض
                .padding(.bottom, 16)     // مسافة بين العنوان وحقل الكتابة

            // الكتابة حرة بأي لغة (عربي أو إنجليزي) — الـ placeholder مجرد أمثلة عشان يوضّح إن الخيار للمستخدم
            TextField("e.g. Coding, Arabic, Drawing", text: $topic)
                .font(.subheadline)       // نفس حجم خط العناوين
                .padding(.bottom, 12)     // يبعّد الخط الرمادي عن النص (قبل الـ overlay)
                .overlay(alignment: .bottom) { Divider() }  // الخط الرمادي تحت الحقل
                .padding(.bottom, 24)     // يبعّد الحقل مع خطه عن العنوان اللي بعده (بعد الـ overlay)

            Text("I want to learn it in a")
                .font(.subheadline)       // خط عادي وأصغر بدل .headline العريض
                .padding(.bottom, 12)     // مسافة قبل أزرار Week / Month / Year

            DurationPicker(selection: $duration)
        }
    }
}
