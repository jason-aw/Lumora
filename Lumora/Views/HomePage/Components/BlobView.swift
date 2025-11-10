//
//  CircleView.swift
//  Lumora
//
//  Created by Jason Andersen Winfrey on 7/11/2025.
//

import SwiftUI

// import mix

struct BlobView: View {
    
    @Bindable var transcriptMic: MicTranscript
    
    let animationSpeed = 5.0
    
    // circle 1 green-ish
    let circle1Color1 = Color(red: 255/255, green: 209/255, blue: 139/255)
    let circle1Color2 = Color(red: 139/255, green: 255/255, blue: 171/255, opacity: 0.7)
    
    @State var circle1Size = 140.0
    @State var circle1OffsetX = 0.0
    @State var circle1OffsetY = 0.0
    
    // circle 2 yellow-ish
    let circle2Color1 = Color(red: 255/255, green: 208/255, blue: 87/255)
    let circle2Color2 = Color(red: 255/255, green: 208/255, blue: 87/255, opacity: 0.08)
    @State var circle2Size = 120.0
    @State var circle2OffsetX = 0.0
    @State var circle2OffsetY = 0.0
    
    // circle 3 purple/orange-ish
    let circle3Color1 = Color(red: 255/255, green: 230/255, blue: 0/255)
    let circle3Color2 = Color(red: 165/255, green: 0/255, blue: 223/255)
    @State var circle3Size = 180.0
    
    @State var circle3OffsetX = 0.0
    @State var circle3OffsetY = 0.0
    
    // var volume = 0
    
    var body: some View {
        VStack {
            ZStack {
                
                Circle()
                    .fill(RadialGradient(colors: [circle3Color1, circle3Color2], center: UnitPoint(x: 0.8, y: 0.4), startRadius: 0, endRadius: 1.2 * circle3Size))
                    .frame(
                        width: circle3Size + (40 * Double(transcriptMic.currSound)),
                        height: circle3Size + (40 * Double(transcriptMic.currSound))
                    )
                    .animation(.easeInOut(duration: 0.2), value: transcriptMic.currSound)
                    .offset(x: circle3OffsetX, y: circle3OffsetY)
                    .opacity(0.67)
                    .onAppear {
                        withAnimation(.easeInOut(duration: 7).repeatForever().speed( animationSpeed)) {
                            circle3OffsetX = .random(in: -150...150)
                            circle3OffsetY = .random(in: -150...150)
                        }
                    }
                
                
                
                Circle()
                    .fill(RadialGradient(colors: [circle1Color1, circle1Color2], center: UnitPoint(x: 0.3, y: 0.7), startRadius: 0, endRadius: 0.4 * circle1Size))
                    .frame(
                        width: circle1Size + (40 * Double(transcriptMic.currSound)),
                        height: circle1Size + (40 * Double(transcriptMic.currSound))
                    )
                    .animation(.easeInOut(duration: 0.2), value: transcriptMic.currSound)
                    .offset(x: circle1OffsetX, y: circle1OffsetY)
                    .opacity(0.67)
                    .onAppear {
                        withAnimation(.easeInOut(duration: 5).repeatForever().speed( animationSpeed)) {
                            circle1OffsetX = .random(in: -150...150)
                            circle1OffsetY = .random(in: -150...150)
                        }
                    }
                
                Circle()
                    .fill(RadialGradient(colors: [circle2Color1, circle2Color2], center: UnitPoint(x: 0.5, y: 0.5), startRadius: 0, endRadius: circle1Size))
                    .frame(
                        width: circle2Size + (40 * Double(transcriptMic.currSound)),
                        height: circle2Size + (40 * Double(transcriptMic.currSound))
                    )
                    .animation(.easeInOut(duration: 0.2), value: transcriptMic.currSound)
                    .offset(x: circle2OffsetX, y: circle2OffsetY)
                    .opacity(0.67)
                    .onAppear {
                        withAnimation(.easeInOut(duration: 3).repeatForever().speed( animationSpeed)) {
                            circle2OffsetX = .random(in: -150...150)
                            circle2OffsetY = .random(in: -150...150)
                        }
                    }
            
            }
            .blendMode(BlendMode.lighten)
            .blur(radius: 20)
        }
    }
    
}

