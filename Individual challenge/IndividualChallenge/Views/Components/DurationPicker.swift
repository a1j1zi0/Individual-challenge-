import SwiftUI

struct DurationPicker: View {
    @Binding var selection: GoalDuration

    var body: some View {
        // GlassEffectContainer يرسم كل الكبسولات الزجاجية مع بعض (أداء أفضل وشكل متناسق)
        GlassEffectContainer(spacing: 8) {
            HStack(spacing: 8) {
                ForEach(GoalDuration.allCases, id: \.self) { duration in
                    Button {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            selection = duration
                        }
                    } label: {
                        Text(duration.title)
                            .font(.subheadline)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .foregroundStyle(selection == duration ? Color.white : Color.gray)
                            // Liquid Glass: المختار زجاج ملوّن برتقالي، والباقي زجاج عادي
                            // interactive() يخلي الزجاج يتفاعل مع اللمس
                            .glassEffect(
                                .regular.tint(selection == duration ? Color.appOrange : nil).interactive(),
                                in: .capsule
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .sensoryFeedback(.selection, trigger: selection)
    }
}
