//
//  BlobView 2.swift
//  Lumora
//
//  Created by Arshia on 7/11/2025.
//

import SwiftUI

// "Lumora" Prismatic AI Bubble
// - Many shades blended (cyan/teal/emerald/blue/ultramarine/violet/magenta)
// - Intelligent shimmer rim, calm breathing, slow drift, micro wobble
// - No pure white cores; center remains rich and soft
// - Centered by default; tap opens RecordingView; draggable
struct AIBubbleView: View {
    
    // MARK: - Animation configuration
    private let driftSpeed = 1.6
    private let breatheDuration = 3.0
    private let wobbleDuration = 8.5
    private let shimmerDuration = 10.0
    
    // MARK: - Palette (lots of shades, no white)
    // Deep foundation
    private let deepInk      = Color(red: 18/255, green: 22/255, blue: 50/255)
    private let deepIndigo   = Color(red: 34/255, green: 20/255, blue: 84/255)
    private let ultramarine  = Color(red: 32/255, green: 52/255, blue: 140/255)
    
    // Blues
    private let blueA        = Color(red: 60/255, green: 110/255, blue: 200/255)
    private let blueB        = Color(red: 90/255, green: 140/255, blue: 230/255)
    private let blueC        = Color(red: 40/255, green: 90/255,  blue: 190/255)
    
    // Teal / Cyan
    private let cyanA        = Color(red: 0/255,   green: 180/255, blue: 200/255)
    private let cyanB        = Color(red: 0/255,   green: 140/255, blue: 160/255)
    private let tealA        = Color(red: 30/255,  green: 160/255, blue: 170/255)
    private let tealB        = Color(red: 60/255,  green: 200/255, blue: 200/255)
    private let emerald      = Color(red: 0/255,   green: 150/255, blue: 120/255)
    
    // Violet / Magenta
    private let violetA      = Color(red: 140/255, green: 110/255, blue: 230/255)
    private let violetB      = Color(red: 100/255, green: 70/255,  blue: 200/255)
    private let magentaA     = Color(red: 210/255, green: 80/255,  blue: 180/255)
    private let magentaB     = Color(red: 120/255, green: 40/255,  blue: 140/255)
    
    // Size
    private let size: CGFloat = 260
    
    // Layer sizes (parallax)
    private let L1: CGFloat = 240 // deep base
    private let L2: CGFloat = 220 // ultramarine/blue
    private let L3: CGFloat = 205 // teal/cyan
    private let L4: CGFloat = 190 // blue/violet bridge
    private let L5: CGFloat = 175 // magenta/violet accent
    private let L6: CGFloat = 160 // emerald/teal accent
    private let L7: CGFloat = 145 // cyan inner accent
    
    // Drift offsets
    @State private var l1x: CGFloat = 0; @State private var l1y: CGFloat = 0
    @State private var l2x: CGFloat = 0; @State private var l2y: CGFloat = 0
    @State private var l3x: CGFloat = 0; @State private var l3y: CGFloat = 0
    @State private var l4x: CGFloat = 0; @State private var l4y: CGFloat = 0
    @State private var l5x: CGFloat = 0; @State private var l5y: CGFloat = 0
    @State private var l6x: CGFloat = 0; @State private var l6y: CGFloat = 0
    @State private var l7x: CGFloat = 0; @State private var l7y: CGFloat = 0
    
    // Life & interactions
    @State private var isPresented = false
    @State private var isPressed = false
    @State private var breathe = false
    @State private var wobble = false
    @State private var shimmer = false
    
    // Dragging
    @State private var dragOffset: CGSize = .zero
    @State private var lastDragOffset: CGSize = .zero
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Ambient halo: soft presence, no white flare
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.white.opacity(0.14),
                                Color.white.opacity(0.05),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: size * 0.8
                        )
                    )
                    .frame(width: size * 1.06, height: size * 1.06)
                    .blur(radius: 24)
                    .opacity(0.8)
                    .scaleEffect(breathe ? 1.03 : 0.985)
                    .animation(.easeInOut(duration: breatheDuration).repeatForever(autoreverses: true), value: breathe)
                
                // Intelligent spectral rim shimmer
                Circle()
                    .stroke(
                        AngularGradient(
                            gradient: Gradient(colors: [
                                cyanA.opacity(0.35),
                                blueB.opacity(0.25),
                                violetA.opacity(0.25),
                                magentaA.opacity(0.28),
                                emerald.opacity(0.25),
                                cyanA.opacity(0.35)
                            ]),
                            center: .center,
                            angle: .degrees(shimmer ? 360 : 0)
                        ),
                        lineWidth: 1.0
                    )
                    .blur(radius: 8)
                    .frame(width: size * 0.93, height: size * 0.93)
                    .opacity(0.33)
                    .animation(.linear(duration: shimmerDuration).repeatForever(autoreverses: false), value: shimmer)
                
                // Multi-hue layered blob (7 layers)
                ZStack {
                    // L1: Deep base (ink -> indigo)
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [deepIndigo, deepInk],
                                center: UnitPoint(x: 0.70, y: 0.36),
                                startRadius: 0,
                                endRadius: 1.2 * L1
                            )
                        )
                        .frame(width: L1, height: L1)
                        .offset(x: l1x, y: l1y)
                        .opacity(0.85)
                        .onAppear {
                            withAnimation(.easeInOut(duration: 9.0).repeatForever().speed(driftSpeed)) {
                                l1x = .random(in: -46...46)
                                l1y = .random(in: -46...46)
                            }
                        }
                    
                    // L2: Ultramarine/Blue depth
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [ultramarine, blueA],
                                center: UnitPoint(x: 0.78, y: 0.42),
                                startRadius: 0,
                                endRadius: 0.78 * L2
                            )
                        )
                        .frame(width: L2, height: L2)
                        .offset(x: l2x, y: l2y)
                        .opacity(0.82)
                        .onAppear {
                            withAnimation(.easeInOut(duration: 8.2).repeatForever().speed(driftSpeed)) {
                                l2x = .random(in: -42...42)
                                l2y = .random(in: -42...42)
                            }
                        }
                    
                    // L3: Teal/Cyan energy
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [tealA, cyanB],
                                center: UnitPoint(x: 0.25, y: 0.75),
                                startRadius: 0,
                                endRadius: 0.64 * L3
                            )
                        )
                        .frame(width: L3, height: L3)
                        .offset(x: l3x, y: l3y)
                        .opacity(0.84)
                        .onAppear {
                            withAnimation(.easeInOut(duration: 7.0).repeatForever().speed(driftSpeed)) {
                                l3x = .random(in: -40...40)
                                l3y = .random(in: -40...40)
                            }
                        }
                    
                    // L4: Blue/Violet bridge
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [violetA, blueB],
                                center: UnitPoint(x: 0.72, y: 0.38),
                                startRadius: 0,
                                endRadius: 0.70 * L4
                            )
                        )
                        .frame(width: L4, height: L4)
                        .offset(x: l4x, y: l4y)
                        .opacity(0.78)
                        .onAppear {
                            withAnimation(.easeInOut(duration: 7.6).repeatForever().speed(driftSpeed)) {
                                l4x = .random(in: -36...36)
                                l4y = .random(in: -36...36)
                            }
                        }
                    
                    // L5: Magenta/Violet accent
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [magentaA.opacity(0.85), magentaB.opacity(0.85)],
                                center: UnitPoint(x: 0.34, y: 0.28),
                                startRadius: 0,
                                endRadius: 0.60 * L5
                            )
                        )
                        .frame(width: L5, height: L5)
                        .offset(x: l5x, y: l5y)
                        .opacity(0.70)
                        .onAppear {
                            withAnimation(.easeInOut(duration: 6.4).repeatForever().speed(driftSpeed)) {
                                l5x = .random(in: -34...34)
                                l5y = .random(in: -34...34)
                            }
                        }
                    
                    // L6: Emerald/Teal accent (intelligent spark)
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [emerald, tealB],
                                center: UnitPoint(x: 0.20, y: 0.55),
                                startRadius: 0,
                                endRadius: 0.58 * L6
                            )
                        )
                        .frame(width: L6, height: L6)
                        .offset(x: l6x, y: l6y)
                        .opacity(0.76)
                        .onAppear {
                            withAnimation(.easeInOut(duration: 6.0).repeatForever().speed(driftSpeed)) {
                                l6x = .random(in: -32...32)
                                l6y = .random(in: -32...32)
                            }
                        }
                    
                    // L7: Cyan inner accent (presence, no white)
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [cyanB.opacity(0.95), cyanA.opacity(0.85)],
                                center: UnitPoint(x: 0.50, y: 0.52),
                                startRadius: 0,
                                endRadius: L4
                            )
                        )
                        .frame(width: L7, height: L7)
                        .offset(x: l7x, y: l7y)
                        .opacity(0.78)
                        .onAppear {
                            withAnimation(.easeInOut(duration: 5.6).repeatForever().speed(driftSpeed)) {
                                l7x = .random(in: -28...28)
                                l7y = .random(in: -28...28)
                            }
                        }
                }
                .blendMode(.screen)   // soft additive across hues
                .blur(radius: 14)     // defined yet dreamy
                .scaleEffect(isPressed ? 0.965 : (breathe ? 1.01 : 1.0))
                .rotationEffect(.degrees(wobble ? 1.4 : -1.4))
                .animation(.easeInOut(duration: wobbleDuration).repeatForever(autoreverses: true), value: wobble)
                .animation(.spring(response: 0.28, dampingFraction: 0.86), value: isPressed)
                .overlay(
                    // Colored rim (no white)
                    Circle()
                        .strokeBorder(
                            LinearGradient(
                                colors: [
                                    violetA.opacity(0.26),
                                    cyanA.opacity(0.22),
                                    magentaA.opacity(0.22),
                                    emerald.opacity(0.22),
                                    blueB.opacity(0.24),
                                    violetA.opacity(0.26)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.1
                        )
                        .blur(radius: 1.2)
                        .padding(6)
                        .opacity(0.6)
                )
                .shadow(color: Color.black.opacity(0.35), radius: 18, x: 0, y: 8)
                .frame(width: size * 0.96, height: size * 0.96)
                .contentShape(Circle())
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Lumora Assistant")
                .accessibilityHint("Double tap to start talking")
                .gesture(
                    DragGesture(minimumDistance: 1)
                        .onChanged { value in
                            isPressed = true
                            let half = (size * 0.96) / 2
                            let padding: CGFloat = 16
                            let proposed = CGSize(
                                width: lastDragOffset.width + value.translation.width,
                                height: lastDragOffset.height + value.translation.height
                            )
                            let minX = -(geo.size.width / 2 - half - padding)
                            let maxX = (geo.size.width / 2 - half - padding)
                            let minY = -(geo.size.height / 2 - half - padding)
                            let maxY = (geo.size.height / 2 - half - padding)
                            
                            dragOffset = CGSize(
                                width: min(max(proposed.width, minX), maxX),
                                height: min(max(proposed.height, minY), maxY)
                            )
                        }
                        .onEnded { _ in
                            isPressed = false
                            lastDragOffset = dragOffset
                        }
                )
                .onTapGesture {
                    lightTap()
                    isPressed = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                        isPressed = false
                        isPresented = true
                    }
                }
            }
            // Centered by default; dragOffset moves it if dragged
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .offset(dragOffset)
            .onAppear {
                breathe = true
                wobble = true
                shimmer = true
            }
            .sheet(isPresented: $isPresented) {
                RecordingView()
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            }
        }
    }
    
    private func lightTap() {
        #if os(iOS)
        let generator = UIImpactFeedbackGenerator(style: .soft)
        generator.impactOccurred()
        #endif
    }
}

#Preview {
    ZStack {
        Color("backgroundColor").ignoresSafeArea()
        AIBubbleView()
    }
}
