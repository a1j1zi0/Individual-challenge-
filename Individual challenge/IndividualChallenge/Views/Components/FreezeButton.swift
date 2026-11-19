import SwiftUI

struct FreezeButton: View {
    let title: String
    let isEnabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)               // خط عادي بدل العريض مثل التصميم
                .frame(width: 240)                // نفس عرض دائرة Log as Learned بدل عرض الشاشة
                .padding(.vertical, 10)           // أنحف شوي (كان 14)
                .foregroundStyle(isEnabled ? Color.white : Color.gray)
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
