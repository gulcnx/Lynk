//
//  Theme.swift
//  Lynk
//
//  Created by gülçin çetin on 2.02.2026.
//

import SwiftUI

extension Color {
    static let lynkBlack = Color(red: 0.1, green: 0.1, blue: 0.12) 
    static let lynkDarkGray = Color(red: 0.16, green: 0.16, blue: 0.18)
    static let lynkYellow = Color(red: 1.0, green: 0.8, blue: 0.0)
}

struct PremiumBackground: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    
    func body(content: Content) -> some View {
        ZStack {
            (colorScheme == .dark ? Color.lynkBlack : Color(uiColor: .systemGroupedBackground))
                .ignoresSafeArea()
            
            content
        }
    }
}

extension View {
    func premiumBackground() -> some View {
        modifier(PremiumBackground())
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .fontWeight(.bold)
            .foregroundStyle(.black) // 👇 FORCE BLACK TEXT (Readability Fix)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.lynkYellow)
            .cornerRadius(12)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
    }
}

// Helper to use it easily
extension ButtonStyle where Self == PrimaryButtonStyle {
    static var lynkPrimary: PrimaryButtonStyle { PrimaryButtonStyle() }
}
