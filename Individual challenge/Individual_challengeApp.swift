//
//  Individual_challengeApp.swift
//  Individual challenge
//
//  Created by Aljazi Alqahatni on 18/11/2026.
//

import SwiftUI

@main
struct Individual_challengeApp: App {
    // @State بدل @StateObject لأن الـ ViewModel صار @Observable
    @State private var activityViewModel = ActivityViewModel()
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(activityViewModel)
                .preferredColorScheme(.dark)
                .onChange(of: scenePhase) { _, phase in
                    if phase == .active { activityViewModel.refresh() }
                }
                // نحدّث الشاشة لما يتغيّر اليوم (12 بالليل) عشان الأزرار ترجع تشتغل.
                // async/await بدل Combine
                .task {
                    for await _ in NotificationCenter.default.notifications(named: .NSCalendarDayChanged) {
                        activityViewModel.refresh()
                    }
                }
                // iOS يرسل هذا التنبيه لما تتغيّر ساعة الجهاز، فنحدّث الشاشة على طول
                // عشان الأزرار ورسالة التحذير تتحدّث بدون ما يطلع المستخدم من التطبيق
                .task {
                    for await _ in NotificationCenter.default.notifications(named: .NSSystemClockDidChange) {
                        activityViewModel.refresh()
                    }
                }
        }
    }
}
