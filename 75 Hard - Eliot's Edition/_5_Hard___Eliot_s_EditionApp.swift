//
//  _5_Hard___Eliot_s_EditionApp.swift
//  75 Hard - Eliot's Edition
//
//  Created by Eliot Paynter on 6/10/25.
//

import SwiftUI
import SwiftData

@main
struct LockInApp: App {
    var body: some Scene {
        WindowGroup {
            HomeView()
                .onAppear {
                    Task {
                        await NotificationManager.shared.requestPermission()
                    }
                }
        }
        .modelContainer(for: [DailyChecklist.self, JournalEntry.self])
    }
}
