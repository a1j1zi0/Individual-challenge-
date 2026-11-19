//
//  Individual_challengeApp.swift
//  Individual challenge
//
//  Created by Aljazi Alqahatni on 18/11/2026.
//

import SwiftUI
import Combine

@main
struct Individual_challengeApp: App {
    @StateObject private var activityViewModel = ActivityViewModel()
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(activityViewModel)
                .preferredColorScheme(.dark)
                .onChange(of: scenePhase) { _, phase in
                    if phase == .active { activityViewModel.refresh() }
                }
                .onReceive(NotificationCenter.default.publisher(for: .NSCalendarDayChanged)) { _ in
                    activityViewModel.refresh()
                }
                // iOS يرسل هذا التنبيه لما تتغيّر ساعة الجهاز، فنحدّث الشاشة على طول
                // عشان الأزرار ورسالة التحذير تتحدّث بدون ما يطلع المستخدم من التطبيق
                .onReceive(NotificationCenter.default.publisher(for: .NSSystemClockDidChange)) { _ in
                    activityViewModel.refresh()
                }
        }
    }
}
