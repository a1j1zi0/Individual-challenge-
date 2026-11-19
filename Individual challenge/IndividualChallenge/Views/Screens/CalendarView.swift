import SwiftUI

struct CalendarView: View {
    @EnvironmentObject private var viewModel: ActivityViewModel

    var body: some View {
        // الشاشة للعرض فقط (view only): الأيام نصوص بدون أزرار أو تفاعل
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ForEach(viewModel.months) { month in
                    MonthView(section: month, weekdayHeaders: viewModel.weekdayHeaders)
                    // خط فاصل بين كل شهر والثاني مثل التصميم
                    Divider()
                }
            }
            .padding()
        }
        // تفتح الشاشة على آخر شهر (الشهر الحالي) بدل أول شهر
        // Bug fix: for: .initialOffset يخلي التأثير على مكان البداية بس،
        // فلو فيه شهر واحد يطلع فوق بدل ما ينزل تحت ويخلي فراغ أسود كبير
        .defaultScrollAnchor(.bottom, for: .initialOffset)
        .background(Color.appBackground.ignoresSafeArea())
        .navigationTitle("Activities")
        .navigationBarTitleDisplayMode(.inline)
    }
}
