import SwiftUI

struct StatCard: View {
    let icon: String
    let color: Color
    let count: Int
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon).foregroundStyle(color)
            Text(count.dayText)
                .font(.subheadline.weight(.semibold))  // أصغر من .headline مثل التصميم
            Text(label)
                .font(.caption2)                       // أصغر من .caption
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        // Liquid Glass: كارد زجاجي بزوايا دائرية
        .glassEffect(.regular, in: .rect(cornerRadius: 20))
    }
}
