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
            
            VStack(spacing: 20) {
                Image(systemName: "person.crop.circle.badge.plus")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 120)
                    .foregroundStyle(Color.lynkMint)
                
                Text("What should we call you?")
                    .font(.title)
                    .bold()
                
                TextField("Your First Name", text: $userName)
                    .font(.headline)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    .padding(.horizontal, 40)
                
                Text("We use this to personalize your dashboard.")
                    .font(.caption)
                    .foregroundStyle(.gray)
            }
            .tag(3)
            
            // Page 4: Get Started
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
