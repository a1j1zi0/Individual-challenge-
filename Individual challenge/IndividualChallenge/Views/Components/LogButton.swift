import SwiftUI

struct LogButton: View {
    let isLogged: Bool
    /// false إذا اليوم متجمّد أو مسجّل، أو الساعة متغيّرة يدوياً
    let isEnabled: Bool
    let action: () -> Void

    // حجم الدائرة يكبر مع حجم الخط (Dynamic Type) بدل 240 ثابت، وما يتعدّى 320 عشان ما تطلع برا الشاشة
    @ScaledMetric(relativeTo: .subheadline) private var scaledSize: CGFloat = 240
    private var size: CGFloat { min(scaledSize, 320) }

    var body: some View {
        Button(action: action) {
            Text(isLogged ? "Logged as Learned" : "Log as Learned")
                .font(.subheadline.weight(.semibold))  // خط أصغر من .title3.bold مثل التصميم
                .multilineTextAlignment(.center)
                .foregroundStyle(isEnabled ? Color.white : Color.gray)
                .padding()
                .frame(width: size, height: size)
                // Liquid Glass: دائرة زجاج برتقالي، وإذا معطّلة زجاج عادي (رمادي)
                .glassEffect(
                    .regular.tint(isEnabled ? Color.appOrange : nil).interactive(isEnabled),
                    in: .circle
                )
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .animation(.easeInOut(duration: 0.3), value: isEnabled)
    }
}
