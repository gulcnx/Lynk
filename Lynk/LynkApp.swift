//
//  LynkApp.swift
//  Lynk
//
//  Created by gülçin çetin on 2.02.2026.
//

import SwiftUI
import SwiftData

@main
struct LynkApp: App {
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding: Bool = false
    @AppStorage("isDarkMode") var isDarkMode: Bool = true
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Client.self,
            Vehicle.self,
            Service.self,
            Expense.self,
            DamagePoint.self
        ])

        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            Group{
                if hasSeenOnboarding {
                    MainTabView()
                } else {
                    OnboardingView(isOnboardingComplete: $hasSeenOnboarding)
                }
            }
            .preferredColorScheme(isDarkMode ? .dark : .light)
        }
        .modelContainer(sharedModelContainer)
    }
}
