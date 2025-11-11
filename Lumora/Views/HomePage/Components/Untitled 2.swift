//
//  PrismaticBubbleView.swift
//  Lumora
//
//  Created by Arshia on 10/11/2025.
//

import SwiftUI

/// A soft, multicolor “glow bubble” that matches the screenshot style:
/// warm yellow/orange center, magenta/violet lower-left, green upper-left,
/// cyan/blue upper-right. Animated with subtle drift + breathing.
struct PrismaticBubbleView: View {
    // Public knobs
    var size: CGFloat = 320
    var blur: CGFloat = 22
    var animationSpeed: Double = 1.0   // 1.0 = default pace
    var breatheAmount: CGFloat = 0.04  // scale delta
    
    // Internal animation state
    @State private var breathe = false
    @State private var wobble = false
    
    // Per-layer drift
    @State private var l1 = CGSize.zero
    @State private var l2 = CGSize.zero
    @State private var l3 = CGSize.zero
    @State private var l4 = CGSize.zero
    @State private var l5 = CGSize.zero
    @State private var l6 = CGSize.zero
    
    // Palette tuned to the screenshot
    private let warmCoreA = Color(red: 1.00, green: 0.90, blue: 0.55)
    private let warmCoreB = Color(red: 1.00, green: 0.74, blue: 0.32)
    
    private let orangeA   = Color(red: 1.00, green: 0.60, blue: 0.25)
    private let orangeB   = Color(red: 0.98, green: 0.45, blue: 0.15)
    
    private let magentaA  = Color(red: 0.76, green: 0.24, blue: 0.65)
    private let violetA   = Color(red: 0.42, green: 0.22, blue: 0.66)
    
    private let greenA    = Color(red: 0.30, green: 0.85, blue: 0.40)
    private let greenB    = Color(red: 0.15, green: 0.55, blue: 0.28)
    
    private let cyanA     = Color(red: 0.30, green: 0.85, blue: 0.95)
    private let blueA     = Color(red: 0.25, green: 0.48, blue: 0.95)
    
    var body: some View {
        ZStack {
            // Layer 1: warm core (largest, soft)
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            warmCoreA.opacity(0.95),
                            warmCoreB.opacity(0.65),
                            Color.clear
                        ],
                        center: UnitPoint(x: 0.53, y: 0.50),
                        startRadius: 0,
                        endRadius: size * 0.62
                    )
                )
                .frame(width: size * 0.95, height: size * 0.95)
                .offset(l1)
                .opacity(0.95)
            
            // Layer 2: orange glow to right side
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            orangeA.opacity(0.85),
                            orangeB.opacity(0.45),
                            Color.clear
                        ],
                        center: UnitPoint(x: 0.72, y: 0.52),
                        startRadius: 0,
                        endRadius: size * 0.60
                    )
                )
                .frame(width: size * 1.00, height: size * 1.00)
                .offset(l2)
                .opacity(0.9)
            
            // Layer 3: magenta/violet lower-left
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            magentaA.opacity(0.65),
                            violetA.opacity(0.55),
                            Color.clear
                        ],
                        center: UnitPoint(x: 0.28, y: 0.78),
                        startRadius: 0,
                        endRadius: size * 0.72
                    )
                )
                .frame(width: size * 1.10, height: size * 1.10)
                .offset(l3)
                .opacity(0.85)
            
            // Layer 4: green glow upper-left
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            greenA.opacity(0.70),
                            greenB.opacity(0.45),
                            Color.clear
                        ],
                        center: UnitPoint(x: 0.18, y: 0.28),
                        startRadius: 0,
                        endRadius: size * 0.65
                    )
                )
                .frame(width: size * 1.05, height: size * 1.05)
                .offset(l4)
                .opacity(0.85)
            
            // Layer 5: cyan/blue upper-right
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            cyanA.opacity(0.70),
                            blueA.opacity(0.55),
                            Color.clear
                        ],
                        center: UnitPoint(x: 0.78, y: 0.22),
                        startRadius: 0,
                        endRadius: size * 0.75
                    )
                )
                .frame(width: size * 1.12, height: size * 1.12)
                .offset(l5)
                .opacity(0.82)
            
            // Layer 6: soft ambient halo
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.white.opacity(0.18),
                            Color.white.opacity(0.06),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: size * 0.85
                    )
                )
                .frame(width: size * 1.18, height: size * 1.18)
                .offset(l6)
                .opacity(0.9)
        }
        .blendMode(.screen)
        .blur(radius: blur)
        .scaleEffect(breathe ? 1 + breatheAmount : 1 - breatheAmount)
        .rotationEffect(.degrees(wobble ? 1.2 : -1.2))
        .animation(.easeInOut(duration: 7.5 / animationSpeed).repeatForever(autoreverses: true), value: breathe)
        .animation(.easeInOut(duration: 9.0 / animationSpeed).repeatForever(autoreverses: true), value: wobble)
        .onAppear {
            breathe = true
            wobble = true
            // start slow, different drift per layer
            withAnimation(.easeInOut(duration: 10 / animationSpeed).repeatForever(autoreverses: true)) {
                l1 = CGSize(width:  10, height: -8)
            }
            withAnimation(.easeInOut(duration: 12 / animationSpeed).repeatForever(autoreverses: true)) {
                l2 = CGSize(width: -14, height:  6)
            }
            withAnimation(.easeInOut(duration: 11 / animationSpeed).repeatForever(autoreverses: true)) {
                l3 = CGSize(width:  12, height: 12)
            }
            withAnimation(.easeInOut(duration: 13 / animationSpeed).repeatForever(autoreverses: true)) {
                l4 = CGSize(width: -10, height: -12)
            }
            withAnimation(.easeInOut(duration: 14 / animationSpeed).repeatForever(autoreverses: true)) {
                l5 = CGSize(width:  16, height: -6)
            }
            withAnimation(.easeInOut(duration: 16 / animationSpeed).repeatForever(autoreverses: true)) {
                l6 = CGSize(width: -6, height: 10)
            }
        }
        .accessibilityHidden(true)
    }
}

#Preview {
    // Keep the preview, but avoid redefining the demo screen here
    ZStack {
        Color(red: 0.07, green: 0.08, blue: 0.10).ignoresSafeArea()
        PrismaticBubbleView(size: 234, blur: 12 , animationSpeed: 10.0, breatheAmount: 0.035)
    }
}
