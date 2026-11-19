import SwiftUI

// تنبيه خاص بدل .alert الجاهز من iOS، لأن الجاهز ما يسمح نخلي زر Update برتقالي ممتلي مثل التصميم
struct UpdateGoalAlert: View {
    let onDismiss: () -> Void
    let onUpdate: () -> Void

    var body: some View {
        ZStack {
            // خلفية سوداء شفافة تغطي الشاشة وتعتّم اللي وراها
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture(perform: onDismiss)   // الضغط برّا المربع يقفل التنبيه
                .accessibilityHidden(true)          // VoiceOver يتجاهل الخلفية ويروح للتنبيه مباشرة

            VStack(alignment: .leading, spacing: 6) {
                Text("Update goal")
                    .font(.headline)
                    .accessibilityAddTraits(.isHeader)
                Text("If you update now, your streak will start over.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.bottom, 14)

                // GlassEffectContainer يرسم الزرّين الزجاجيين مع بعض
                GlassEffectContainer(spacing: 10) {
                    HStack(spacing: 10) {
                        // Dismiss: زجاج عادي (رمادي)
                        Button(action: onDismiss) {
                            Text("Dismiss")
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .foregroundStyle(Color.white)
                                .glassEffect(.regular.interactive(), in: .capsule)
                        }
                        // Update: زجاج برتقالي مثل التصميم
                        Button(action: onUpdate) {
                            Text("Update")
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .foregroundStyle(Color.white)
                                .glassEffect(.regular.tint(Color.appOrange).interactive(), in: .capsule)
                        }
                    }
                }
                .font(.subheadline.weight(.medium))
                .buttonStyle(.plain)
            }
            .padding(16)
            .frame(width: 280)
            // Liquid Glass: مربع التنبيه زجاجي بزوايا دائرية
            .glassEffect(.regular, in: .rect(cornerRadius: 24))
            // Bug fix: كان VoiceOver يشوف زر Update بس. الحين يشوف العنوان والرسالة والزرّين
            .accessibilityElement(children: .contain)
            .accessibilityAddTraits(.isModal)
        }
    }
}
