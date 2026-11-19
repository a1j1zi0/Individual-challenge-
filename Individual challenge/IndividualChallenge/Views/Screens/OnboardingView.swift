import SwiftUI

struct OnboardingView: View {
    @Environment(ActivityViewModel.self) private var activity
    @State private var viewModel = OnboardingViewModel()

    var body: some View {
        // spacing: 0 بدل مسافة موحّدة، عشان كل عنصر ياخذ مسافته الخاصة (المسافات في التصميم مو متساوية)
        VStack(alignment: .leading, spacing: 0) {
            Image(systemName: "flame.fill")
                .font(.system(size: 34))          // حجم الأيقونة صار أصغر (كان 44) مثل التصميم
                .foregroundStyle(Color.appOrange)
                .frame(maxWidth: .infinity)       // يوسّط الأيقونة أفقياً
                .padding(.top, 40)                // ينزّل الأيقونة شوي عن أعلى الشاشة

            // فراغ ثابت بارتفاع 80 بين الأيقونة والعنوان
            Spacer().frame(height: 80)

            // spacing: 4 عشان العنوان والنص اللي تحته يكونون قريبين
            VStack(alignment: .leading, spacing: 4) {
                // "Hello" بخط عادي و"Learner" بخط عريض
                // Bug fix: دمج النصوص بـ + صار deprecated في iOS 26، فاستخدمنا interpolation بدالها
                Text("Hello \(Text("Learner").bold())")
                    .font(.largeTitle)            // الحجم الكبير ينطبق على الكلمتين
                Text("This app will help you learn everyday!")
                    .font(.subheadline)           // خط أصغر للوصف
                    .foregroundStyle(.secondary)  // لون رمادي
            }
            .padding(.bottom, 32)                 // مسافة بين العنوان وبداية الفورم

            GoalForm(topic: $viewModel.topic, duration: $viewModel.duration)

            // يدفع الزر لأسفل الشاشة
            Spacer()

            // الزر والنص اللي تحته مجموعة وحدة بينهم مسافة 12
            VStack(spacing: 12) {
                Button {
                    if let goal = viewModel.makeGoal() {
                        activity.setGoal(goal)
                    }
                } label: {
                    // شلنا .frame(maxWidth: .infinity) عشان الزر يصير على قد النص بدل عرض الشاشة كامل
                    Text("Start Learning")
                        .font(.body.weight(.medium))  // خط أخف من .headline مثل التصميم
                        .padding(.horizontal, 20)     // مسافة يمين ويسار داخل الكبسولة
                        .padding(.vertical, 12)       // ارتفاع الزر (كان 14)
                        .foregroundStyle(Color.white)
                        // Liquid Glass: زجاج برتقالي إذا كتب المستخدم موضوع، زجاج عادي (رمادي) إذا الحقل فاضي
                        .glassEffect(
                            .regular.tint(viewModel.canStart ? Color.appOrange : nil).interactive(viewModel.canStart),
                            in: .capsule
                        )
                }
                .disabled(!viewModel.canStart)        // الزر معطّل لين يكتب المستخدم شي

                Text("You can edit your desire later")
                    .font(.caption2)                  // أصغر من .caption مثل التصميم
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)               // يوسّط الزر والنص أفقياً
        }
        .padding(.horizontal)                         // مسافة يمين ويسار للشاشة كاملة
        .padding(.bottom, 8)                          // مسافة صغيرة تحت
        .background(Color.appBackground.ignoresSafeArea())
    }
}
