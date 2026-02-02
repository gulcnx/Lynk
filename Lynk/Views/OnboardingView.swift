//
//  OnboardingView.swift
//  Lynk
//
//  Created by gülçin çetin on 2.02.2026.
//

import SwiftUI

struct OnboardingView: View {
    // This binding controls the "Game Over" state of onboarding
    @Binding var isOnboardingComplete: Bool
    
    var body: some View {
        TabView {
            // Page 1
            OnboardingPage(
                image: "person.2.circle.fill",
                title: "Manage Clients",
                desc: "Keep track of your customers and their contact info in one place."
            )
            
            // Page 2
            OnboardingPage(
                image: "stopwatch.fill",
                title: "Track Projects",
                desc: "Log hours, set rates, and calculate your earnings instantly."
            )
            
            // Page 3 (With Start Button)
            VStack {
                OnboardingPage(
                    image: "checkmark.seal.fill",
                    title: "Get Paid",
                    desc: "Generate professional PDF invoices and get paid faster."
                )
                
                Button(action: {
                    withAnimation {
                        isOnboardingComplete = true
                    }
                }) {
                    Text("Get Started")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 50)
            }
        }
        .tabViewStyle(.page) // Makes it swipeable dots
        .indexViewStyle(.page(backgroundDisplayMode: .always))
    }
}

// Helper View for Pages
struct OnboardingPage: View {
    let image: String
    let title: String
    let desc: String
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: image)
                .resizable()
                .scaledToFit()
                .frame(height: 150)
                .foregroundStyle(.blue.gradient)
            
            Text(title)
                .font(.system(.largeTitle, design: .rounded)) // Premium Font
                .bold()
            
            Text(desc)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 30)
        }
        .padding()
    }
}
