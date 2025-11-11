//
//  CircleView.swift
//  Lumora
//
//  Created by Jason Andersen Winfrey on 7/11/2025.
//

import SwiftUI

struct BlobView: View {
    @Binding var volume: Double

    let animationSpeed = 5.0

    // circle 1 green-ish
    let circle1Colors = [Color(red: 255/255, green: 209/255, blue: 139/255),
                         Color(red: 139/255, green: 255/255, blue: 171/255, opacity: 0.7)]
    
    let baseCircle1Size = 140.0
    @State var circle1Size = 140.0
    @State var circle1OffsetX = 0.0
    @State var circle1OffsetY = 0.0
    
    // circle 2 yellow-ish
    let circle2Colors = [Color(red: 255/255, green: 208/255, blue: 87/255),
                         Color(red: 255/255, green: 208/255, blue: 87/255, opacity: 0.08)]
    
    let baseCircle2Size = 120.0
    @State var circle2Size = 120.0
    @State var circle2OffsetX = 0.0
    @State var circle2OffsetY = 0.0
    
    // circle 3 purple/orange-ish
    let circle3Colors = [Color(red: 255/255, green: 230/255, blue: 0/255),
                         Color(red: 165/255, green: 0/255, blue: 223/255)]
    
    let baseCircle3Size = 180.0
    @State var circle3Size = 180.0
    @State var circle3OffsetX = 0.0
    @State var circle3OffsetY = 0.0

    @State private var smoothedLevel: Double = 0.0
    
    var body: some View {
        VStack {
            ZStack {
                // Circle 3
                Circle()
                    .fill(RadialGradient(colors: circle3Colors, center: UnitPoint(x: 0.8, y: 0.4), startRadius: 0, endRadius: 1.2 * circle3Size))
                    .frame(width: circle3Size, height: circle3Size)
                    .offset(x: circle3OffsetX, y: circle3OffsetY)
                    .opacity(0.67)

                // Circle 1
                Circle()
                    .fill(RadialGradient(colors: circle1Colors, center: UnitPoint(x: 0.3, y: 0.7), startRadius: 0, endRadius: 0.4 * circle1Size))
                    .frame(width: circle1Size, height: circle1Size)
                    .offset(x: circle1OffsetX, y: circle1OffsetY)
                    .opacity(0.67)

                // Circle 2
                Circle()
                    .fill(RadialGradient(colors: circle2Colors, center: UnitPoint(x: 0.5, y: 0.5), startRadius: 0, endRadius: circle1Size))
                    .frame(width: circle2Size, height: circle2Size)
                    .offset(x: circle2OffsetX, y: circle2OffsetY)
                    .opacity(0.67)
            }
            .blendMode(BlendMode.lighten)
            .blur(radius: 20)
        }
        .task {
            // This block will run as long as the view is present
            while true {
                await MainActor.run {
                    withAnimation(.easeInOut(duration: 2.0)) {
                        circle1OffsetX = .random(in: -150...150)
                        circle1OffsetY = .random(in: -150...150)
                        circle2OffsetX = .random(in: -150...150)
                        circle2OffsetY = .random(in: -150...150)
                        circle3OffsetX = .random(in: -150...150)
                        circle3OffsetY = .random(in: -150...150)
                    }
                }
                // sleep for 2 seconds
                try? await Task.sleep(nanoseconds: 2_000_000_000)
            }
        }
        .task {
            let sampleIntervalNs: UInt64 = 33_000_000 // ~30Hz
            let smoothingFactor = 0.12 // smaller -> smoother
            while !Task.isCancelled {
                // read the raw level (no UI work)
                let rawLevel = volume
                // exponential smoothing
                smoothedLevel = (1.0 - smoothingFactor) * smoothedLevel + smoothingFactor * rawLevel

                // compute delta and update sizes on main actor
                let delta = 40.0 * smoothedLevel
                await MainActor.run {
                    // short animation for a smoother visual response; low-frequency updates avoid contention
                    withAnimation(.easeInOut(duration: 0.12)) {
                        circle1Size = baseCircle1Size + delta
                        circle2Size = baseCircle2Size + delta
                        circle3Size = baseCircle3Size + delta
                    }
                }

                try? await Task.sleep(nanoseconds: sampleIntervalNs)
            }
        }
    }
}
