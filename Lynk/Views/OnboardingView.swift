//
//  OnboardingView.swift
//  Lynk
//
//  Created by gülçin çetin on 2.02.2026.
//

import SwiftUI

struct OnboardingView: View {
    @Binding var isOnboardingComplete: Bool
    @State private var currentPage = 0
    @AppStorage("userName") var userName: String = "User"
    @AppStorage("currencyCode") private var currencyCode: String = "USD"
    
    var body: some View {
        TabView(selection: $currentPage) {
            // Page 1: Clients
            OnboardingPage(
                image: "person.2.circle.fill",
                title: "Manage Clients",
                desc: "Keep track of your customers and contact them in one tap."
            )
            .tag(0)
            
            // Page 2: Timer
            OnboardingPage(
                image: "play.circle.fill",
                title: "Track Time",
                desc: "Use the built-in Timer on project pages to log your hours automatically."
            )
            .tag(1)
            
            // Page 3: Expenses
            OnboardingPage(
                image: "creditcard.fill",
                title: "Track Profit",
                desc: "Log your business expenses to see your true Net Profit."
            )
            .tag(2)
            
            // Page 4: Currency Selection
            VStack(spacing: 20) {
                Image(systemName: "banknote.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 100)
                    .foregroundStyle(Color.lynkMint)
                
                Text("Select Your Currency")
                    .font(.title)
                    .bold()
                    .primaryText()
                
                Text("Choose the currency you use for your detailing business.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 30)
                
                Picker("Currency", selection: $currencyCode) {
                    ForEach(["USD", "EUR", "TRY", "GBP", "CAD", "AUD", "JPY"], id: \.self) { code in
                        Text(code).tag(code)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 40)
                
                Button(action: {
                    withAnimation {
                        currentPage += 1
                    }
                }) {
                    Text("Continue")
                        .font(.headline)
                        .bold()
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.lynkMint)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .padding(.horizontal, 40)
                .padding(.top, 20)
            }
            .tag(3)
            
            // Page 5: Name Input
            VStack(spacing: 20) {
                Image(systemName: "person.crop.circle.badge.plus")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 120)
                    .foregroundStyle(Color.lynkMint)
                
                Text("What should we call you?")
                    .font(.title)
                    .bold()
                
                HStack(spacing: 12) {
                    TextField("Your First Name", text: $userName)
                        .font(.headline)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                    
                    Button(action: {
                        // Smoothly slide to the final onboarding page
                        withAnimation {
                            currentPage = 4
                        }
                    }) {
                        Image(systemName: "arrow.right")
                            .font(.headline)
                            .foregroundStyle(.black)
                            .frame(width: 50, height: 50)
                            .background(Color.lynkMint)
                            .clipShape(Circle())
                    }
                    // Prevent clicking if the name is empty
                    .disabled(userName.isEmpty)
                    .opacity(userName.isEmpty ? 0.5 : 1.0)
                }
                .padding(.horizontal, 40)
                
                Text("We use this to personalize your dashboard.")
                    .font(.caption)
                    .foregroundStyle(.gray)
            }
            .tag(4)
            
            // Page 5: Get Started
            VStack {
                OnboardingPage(
                    image: "checkmark.seal.fill",
                    title: "Get Paid",
                    desc: "Generate professional PDF invoices and send them instantly."
                )
                
                Button(action: {
                    withAnimation {
                        isOnboardingComplete = true
                    }
                }) {
                    Text("Start Using Lynk")
                        .font(.headline)
                        .bold()
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.lynkMint)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 50)
            }
            .tag(4)
        }
        .tabViewStyle(.page)
        .indexViewStyle(.page(backgroundDisplayMode: .always))
        .premiumBackground()
    }
}

struct OnboardingPage: View {
    let image: String
    let title: String
    let desc: String
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: image)
                .resizable()
                .scaledToFit()
                .frame(height: 120)
                .foregroundStyle(Color.lynkMint)
            
            Text(title)
                .font(.system(.largeTitle, design: .rounded))
                .bold()
                .foregroundStyle(colorScheme == .dark ? .white : .black)
            
            Text(desc)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 30)
        }
        .padding()
    }
}
