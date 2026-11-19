import Foundation

extension Int {
    var dayText: String {
        // حسب المتطلبات: الرقم 1 ياخذ "Day"، وأي رقم ثاني ياخذ "Days"
        self == 1 ? "1 Day" : "\(self) Days"
    }
}
