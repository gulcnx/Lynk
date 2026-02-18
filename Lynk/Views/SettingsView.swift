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
            VStack(spacing: 0) {
                Form {
                    // --- SECTION 1: GOALS ---
                    Section(header: Text("Business Goals")) {
                        HStack {
                            Image(systemName: "target")
                                .foregroundStyle(Color.lynkMint)
                            Text("Monthly Goal")
                            Spacer()
                            TextField("Amount", value: $monthlyGoal, format: .currency(code: "USD"))
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 100)
                        }
                    }
                    .listRowBackground(colorScheme == .dark ? Color.lynkCardDark : Color.lynkCardLight)

                    // --- SECTION 2: APPEARANCE ---
                    Section(header: Text("Appearance")) {
                        Toggle(isOn: $isDarkMode) {
                            HStack {
                                Image(systemName: isDarkMode ? "moon.stars.fill" : "sun.max.fill")
                                    .foregroundStyle(Color.lynkMint)
                                Text("Dark Mode")
                            }
                        }
                        .tint(Color.lynkMint)
                    }
                    .listRowBackground(colorScheme == .dark ? Color.lynkCardDark : Color.lynkCardLight)
                    
                    // --- SECTION 3: PRO UPGRADE ---
                    Section(header: Text("Premium")) {
                        VStack(spacing: 15) {
                            HStack {
                                ZStack {
                                    Circle()
                                        .fill(Color.lynkMint.opacity(0.2))
                                        .frame(width: 40, height: 40)
                                    Image(systemName: "crown.fill")
                                        .foregroundStyle(Color.lynkMint)
                                }
                                VStack(alignment: .leading) {
                                    Text("Upgrade to Pro")
                                        .font(.headline)
                                        .primaryText()
                                    Text("Unlimited clients & branding")
                                        .font(.caption)
                                        .secondaryText()
                                }
                                Spacer()
                            }
                            
                            Button("Upgrade for $9.99") {
                                // Purchase logic
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.lynkMint)
                            .foregroundStyle(.black)
                            .cornerRadius(12)
                        }
                        .padding(.vertical, 8)
                    }
                    .listRowBackground(colorScheme == .dark ? Color.lynkCardDark : Color.lynkCardLight)
                }
                .scrollContentBackground(.hidden)
                
                // --- FOOTER ---
                VStack(spacing: 8) {
                    Image(systemName: "sparkles")
                        .font(.title3)
                        .foregroundStyle(LinearGradient.lynkMintGradient)
                    Text("LYNK STUDIO")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .tracking(3)
                        .secondaryText()
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 10)
                .padding(.bottom, 20)
                .background(Color.clear)
            }
            .premiumBackground()
            .navigationTitle("Settings")
        }
    }
}
