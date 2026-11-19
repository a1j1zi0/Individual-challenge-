import SwiftUI

struct LogButton: View {
    let isLogged: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(isLogged ? "Logged as Learned" : "Log as Learned")
                .font(.subheadline.weight(.semibold))  // خط أصغر من .title3.bold مثل التصميم
                .foregroundStyle(isLogged ? Color.gray : Color.white)
                .frame(width: 240, height: 240)
                // Liquid Glass: دائرة زجاج برتقالي، وبعد التسجيل زجاج عادي (رمادي)
                .glassEffect(
                    .regular.tint(isLogged ? nil : Color.appOrange).interactive(!isLogged),
                    in: .circle
                )
        }
        .buttonStyle(.plain)
        .disabled(isLogged)
        .animation(.easeInOut(duration: 0.3), value: isLogged)
    }
}
