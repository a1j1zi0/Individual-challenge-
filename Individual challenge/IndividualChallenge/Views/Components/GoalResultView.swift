import SwiftUI

struct GoalResultView: View {
    let isCompleted: Bool
    let onSetGoal: () -> Void

    var body: some View {
        VStack(spacing: 4) {
            // أيقونة "Goal not met" صارت xmark.seal (نجمة فيها X) مثل التصميم
            Image(systemName: isCompleted ? "hands.clap.fill" : "xmark.seal")
                .font(.system(size: 36))           // أصغر شوي (كان 44)
                .foregroundStyle(Color.appOrange)
                .padding(.bottom, 12)              // مسافة بين الأيقونة والعنوان
            Text(isCompleted ? "Well done!" : "You didn't reach your goal this time.")
                .font(.subheadline.weight(.semibold))  // أصغر من .headline مثل التصميم
                .multilineTextAlignment(.center)
            Text(isCompleted ? "Ready for your next goal?" : "Want to set another goal?")
                .font(.caption)                    // أصغر من .subheadline
                .foregroundStyle(.secondary)

            // زر كبسولة برتقالي فيه أيقونة + نص بدل .borderedProminent
            Button(action: onSetGoal) {
                Label("Set a goal", systemImage: "target")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Color.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    // Liquid Glass: كبسولة زجاج برتقالي
                    .glassEffect(.regular.tint(Color.appOrange).interactive(), in: .capsule)
            }
            .buttonStyle(.plain)
            .padding(.top, 48)                     // مسافة كبيرة بين النص والزر مثل التصميم
        }
    }
}
