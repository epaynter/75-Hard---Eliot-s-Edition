//
//  LockInApp.swift
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
                    print("✅ LockInApp launched successfully with HomeView")
                    Task {
                        await NotificationManager.shared.requestPermission()
                    }
                }
        }
        .modelContainer(for: [
            DailyChecklist.self,
            JournalEntry.self,
            Supplement.self,
            ChallengeSettings.self,
            NotificationPreference.self
        ])
    }
}
