//
//  PaywallView.swift
//  Lynk
//
//  Created by gülçin çetin on 18.02.2026.
//

import SwiftUI

struct PaywallView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var store: StoreManager

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Spacer(minLength: 40)
                
                // --- ICON & HEADER ---
                Image(systemName: "crown.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(LinearGradient.lynkMintGradient)
                    .shadow(color: Color.lynkMint.opacity(0.4), radius: 12, y: 8)
                    .padding(.bottom, 24)
                
                VStack(spacing: 12) {
                    Text("Lynk Pro")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .primaryText()
                    
                    Text("Elevate your detailing business.")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary.opacity(0.8))
                }
                .padding(.bottom, 40)
                
                // --- FEATURE LIST ---
                VStack(alignment: .leading, spacing: 28) {
                    FeatureRow(icon: "person.3.fill", title: "Unlimited Clients", subtitle: "Remove the 5-client limit")
                    FeatureRow(icon: "doc.plaintext.fill", title: "Custom Invoices", subtitle: "Generate professional PDFs")
                    FeatureRow(icon: "chart.pie.fill", title: "Advanced Analytics", subtitle: "Unlock all dashboard features")
                    FeatureRow(icon: "heart.fill", title: "Support Indie", subtitle: "Support the creator of Lynk 🤍")
                }
                .padding(.horizontal, 30)
                
                Spacer()
                
                // --- PURCHASE SECTION ---
                VStack(spacing: 16) {
                    Button(action: {
                        Task {
                            await store.purchase()
                            if store.hasProAccess {
                                dismiss()
                            }
                        }
                    }) {
                        Text("Upgrade for $9.99 / month")
                            .font(.headline)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(LinearGradient.lynkMintGradient)
                            .foregroundStyle(.black)
                            .cornerRadius(16)
                            .shadow(color: Color.lynkMint.opacity(0.3), radius: 10, y: 5)
                    }
                    
                    Button("Restore Purchases") {
                        Task {
                            await store.updateSubscriptionStatus()
                            if store.hasProAccess { dismiss() }
                        }
                    }
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 30)
            }
            .premiumBackground()
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.gray.opacity(0.5))
                            .font(.title2)
                    }
                }
            }
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        HStack(spacing: 18) {
            ZStack {
                Circle()
                    .fill(Color.lynkMint.opacity(0.12))
                    .frame(width: 48, height: 48)
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(Color.lynkMint)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .primaryText()
                Text(subtitle)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
