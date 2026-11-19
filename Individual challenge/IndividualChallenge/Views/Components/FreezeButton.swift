import SwiftUI

struct FreezeButton: View {
    let title: LocalizedStringResource
    let isEnabled: Bool
    let action: () -> Void

    // نفس عرض دائرة Log as Learned، ويكبر مع حجم الخط (Dynamic Type)
    @ScaledMetric(relativeTo: .subheadline) private var scaledWidth: CGFloat = 240
    private var width: CGFloat { min(scaledWidth, 320) }

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(.medium))
                .frame(width: width)
                .padding(.vertical, 10)
                // Contrast: النص الأبيض فوق الأزرق الفاتح كان ضعيف (أقل من 3:1)،
                // فصار كحلي غامق فوق الأزرق، ورمادي إذا الزر معطّل
                .foregroundStyle(isEnabled ? Color.appNavy : Color.gray)
                // Liquid Glass: زجاج أزرق إذا الزر شغّال، وزجاج عادي (رمادي) إذا معطّل
                .glassEffect(
                    .regular.tint(isEnabled ? Color.appBlue : nil).interactive(isEnabled),
                    in: .capsule
                )
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
    }
}
