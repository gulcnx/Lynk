//
//  SettingsView.swift
//  Lynk
//
//  Created by gülçin çetin on 10.02.2026.
//

import SwiftUI
import PhotosUI

struct SettingsView: View {
    @AppStorage("userName") private var userName: String = "User"
    @AppStorage("isDarkMode") private var isDarkMode = true
    @AppStorage("monthlyGoal") private var monthlyGoal: Double = 5000.0
    
    @AppStorage("userLogoData") private var userLogoData: Data = Data()
    
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var store: StoreManager
    
    @State private var showPaywall = false
    
    @State private var logoItem: PhotosPickerItem?
    @State private var logoImage: Image?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Form {
                    // --- SECTION 1: BUSINESS PROFILE ---
                    Section(header: Text("Business Profile")) {
                        HStack {
                            Image(systemName: "person.fill")
                                .foregroundStyle(Color.lynkMint)
                            Text("Name")
                            Spacer()
                            TextField("Your Name", text: $userName)
                                .multilineTextAlignment(.trailing)
                                .textInputAutocapitalization(.words)
                        }
                        
                        if store.hasProAccess {
                            PhotosPicker(selection: $logoItem, matching: .images, photoLibrary: .shared()) {
                                HStack {
                                    Image(systemName: "photo.badge.plus")
                                        .foregroundStyle(Color.lynkMint)
                                    Text("Invoice Logo")
                                        .foregroundStyle(.primary)
                                    Spacer()
                                    if let logoImage {
                                        logoImage
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 40, height: 40)
                                            .cornerRadius(6)
                                    } else {
                                        Text("Select")
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                            .onChange(of: logoItem) { oldValue, newValue in
                                Task {
                                    if let data = try? await newValue?.loadTransferable(type: Data.self) {
                                        userLogoData = data
                                        if let uiImage = UIImage(data: data) {
                                            logoImage = Image(uiImage: uiImage)
                                        }
                                    }
                                }
                            }
                            
                            if !userLogoData.isEmpty {
                                Button(role: .destructive) {
                                    userLogoData = Data()
                                    logoImage = nil
                                    logoItem = nil
                                } label: {
                                    HStack {
                                        Image(systemName: "trash")
                                        Text("Remove Logo")
                                    }
                                }
                            }
                            
                        } else {
                            Button(action: { showPaywall = true }) {
                                HStack {
                                    Image(systemName: "lock.fill")
                                        .foregroundStyle(.gray)
                                    Text("Invoice Logo")
                                        .foregroundStyle(.primary)
                                    Spacer()
                                    Text("Pro Feature")
                                        .font(.caption)
                                        .bold()
                                        .foregroundStyle(Color.lynkMint)
                                }
                            }
                        }
                    }
                    .listRowBackground(colorScheme == .dark ? Color.lynkCardDark : Color.lynkCardLight)
                    
                    // --- SECTION 2: GOALS ---
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

                    // --- SECTION 3: APPEARANCE ---
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
                    
                    // --- SECTION 4: PRO UPGRADE ---
                    Section(header: Text("Premium")) {
                        VStack(spacing: 15) {
                            HStack {
                                ZStack {
                                    Circle()
                                        .fill(Color.lynkMint.opacity(0.2))
                                        .frame(width: 40, height: 40)
                                    Image(systemName: store.hasProAccess ? "checkmark.seal.fill" : "crown.fill")
                                        .foregroundStyle(LinearGradient.lynkMintGradient)
                                }
                                VStack(alignment: .leading) {
                                    Text(store.hasProAccess ? "Premium" : "Upgrade to Pro")
                                        .font(.headline)
                                        .foregroundStyle(.primary)
                                    Text(store.hasProAccess ? "Thank you for supporting Lynk 🤍" : "Unlimited clients & custom invoices")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                            }
                            
                            Button(action: {
                                if !store.hasProAccess {
                                    showPaywall = true
                                }
                            }) {
                                HStack {
                                    Text(store.hasProAccess ? "You are a PRO" : "View Premium Features")
                                }
                                .font(.headline)
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(LinearGradient.lynkMintGradient)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(store.hasProAccess ? Color.white : Color.clear, lineWidth: 2)
                            )
                            .foregroundStyle(store.hasProAccess ? Color.white : .black)
                        }
                        .padding(.vertical, 8)
                    }
                    .listRowBackground(colorScheme == .dark ? Color.lynkCardDark : Color.lynkCardLight)
                }
                .scrollContentBackground(.hidden)
                
                // --- FOOTER ---
                HStack(spacing: 8) {
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
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
            .onAppear {
                if !userLogoData.isEmpty, let uiImage = UIImage(data: userLogoData) {
                    logoImage = Image(uiImage: uiImage)
                }
            }
        }
    }
}
