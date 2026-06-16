//
//  Theme.swift
//  Lynk
//
//  Created by gülçin çetin on 2.02.2026.
//

import SwiftUI

extension Color {
    // --- THE "DEEP BLUE & MINT" PALETTE ---
    
    // Backgrounds
    static let lynkDarkBlue = Color(hex: "050A14") // Deepest Midnight Blue
    static let lynkCardDark = Color(hex: "101626") // Slightly lighter Navy for cards
    
    // Light Mode Equivalents
    static let lynkLightBackground = Color(hex: "F2F4F7") // Crisp Light Gray
    static let lynkCardLight = Color(hex: "FFFFFF")       // Pure White
    
    // Accents
    static let lynkMint = Color(hex: "00F260")       // Electric Mint
    static let lynkTeal = Color(hex: "0575E6")       // Deep Teal
    static let lynkRed = Color(hex: "FF453A")        // Alert Red
}

// Helper for Hex Colors
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
    }
}

// --- DYNAMIC GRADIENTS ---
extension LinearGradient {
    static var lynkMintGradient: LinearGradient {
        LinearGradient(
            colors: [Color.lynkMint, Color.lynkTeal],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

// --- VIEW MODIFIERS ---

// 1. Background Modifier (Fixes Dark/Light Mode)
struct PremiumBackground: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    
    func body(content: Content) -> some View {
        ZStack {
            // Dynamic switching based on mode
            (colorScheme == .dark ? Color.lynkDarkBlue : Color.lynkLightBackground)
                .ignoresSafeArea()
            
            content
        }
    }
}

// 2. Card Modifier (Fixes Dark/Light Mode)
struct LuxuryCard: ViewModifier {
    @Environment(\.colorScheme) var colorScheme

    func body(content: Content) -> some View {
        content
            .background(colorScheme == .dark ? Color.lynkCardDark : Color.lynkCardLight)
            .cornerRadius(16)
            .shadow(
                color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.05),
                radius: 10, x: 0, y: 5
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        colorScheme == .dark ? Color.white.opacity(0.1) : Color.black.opacity(0.05),
                        lineWidth: 1
                    )
            )
    }
}

extension View {
    func premiumBackground() -> some View {
        modifier(PremiumBackground())
    }
    
    func luxuryCardStyle() -> some View {
        modifier(LuxuryCard())
    }
    
    // Helper to color text based on mode
    func primaryText() -> some View {
        self.foregroundStyle(Color.primary)
    }
    
    func secondaryText() -> some View {
        self.foregroundStyle(Color.secondary)
    }
}
