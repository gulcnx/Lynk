//
//  SettingsView.swift
//  Lynk
//
//  Created by gülçin çetin on 2.02.2026.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("isDarkMode") private var isDarkMode = true
    @AppStorage("monthlyGoal") private var monthlyGoal: Double = 5000.0
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationStack {
            Form {
                // SECTION 1: GOALS (New Feature)
                Section {
                    HStack {
                        Image(systemName: "target")
                            .foregroundStyle(Color.lynkYellow)
                        Text("Monthly Goal")
                        Spacer()
                        TextField("Amount", value: $monthlyGoal, format: .currency(code: "USD"))
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 100)
                    }
                } header: {
                    Text("Business Goals")
                }
                .listRowBackground(colorScheme == .dark ? Color.lynkDarkGray : Color.white)

                // SECTION 2: APPEARANCE
                Section {
                    Toggle(isOn: $isDarkMode) {
                        HStack {
                            Image(systemName: isDarkMode ? "moon.stars.fill" : "sun.max.fill")
                                .foregroundStyle(Color.lynkYellow)
                            Text("Dark Mode")
                        }
                    }
                    .tint(Color.lynkYellow)
                } header: {
                    Text("Appearance")
                }
                .listRowBackground(colorScheme == .dark ? Color.lynkDarkGray : Color.white)
                
                // SECTION 3: PRO UPGRADE
                Section {
                    VStack(spacing: 15) {
                        HStack {
                            ZStack {
                                Circle()
                                    .fill(Color.lynkYellow.opacity(0.2))
                                    .frame(width: 40, height: 40)
                                Image(systemName: "crown.fill")
                                    .foregroundStyle(Color.lynkYellow)
                            }
                            VStack(alignment: .leading) {
                                Text("Upgrade to Pro")
                                    .font(.headline)
                                Text("Unlimited clients & branding")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                        }
                        
                        Button("Upgrade for $9.99") {
                            // Purchase logic
                        }
                        .buttonStyle(.lynkPrimary)
                    }
                    .padding(.vertical, 8)
                } header: {
                    Text("Premium")
                }
                .listRowBackground(colorScheme == .dark ? Color.lynkDarkGray : Color.white)
            }
            .scrollContentBackground(.hidden)
            .premiumBackground()
            .navigationTitle("Settings")
        }
    }
}
