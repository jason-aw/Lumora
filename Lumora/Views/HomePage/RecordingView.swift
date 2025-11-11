//
//  RecordingView.swift
//  Lumora
//
//  Created by Jason Andersen Winfrey on 7/11/2025.
//

import SwiftUI
import AVFAudio

struct RecordingView: View {
    @State private var transcriptMic = MicTranscript()
    
    var body: some View {
        VStack(spacing: 24) {
            // Live value
            Text(String(format: "Volume: %.2f", transcriptMic.currSound))
                .font(.system(.body, design: .monospaced))
                .foregroundStyle(.secondary)
            
            // Bubble under test
            FinalBubbleView(size: 234, blur: 12, animationSpeed: 10.0, volume: $transcriptMic.currSound)
            
            // TEMP: Manual control to simulate volume 0...1
            VStack(alignment: .leading, spacing: 8) {
                Text("Test Volume")
                    .foregroundStyle(.secondary)
                Slider(value: $transcriptMic.currSound, in: 0...1)
            }
            .padding(.horizontal)
            
            // Speech text
            Text(transcriptMic.currSpeech)
                .padding(.top, 8)
            
            // Mic control
            Button ("Toggle Recording") {
                if transcriptMic.audioEngine.isRunning {
                    transcriptMic.stopListening()
                } else {
                    transcriptMic.startListening()
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .overlay(
            Group {
                if transcriptMic.loading {
                    ProgressView("Thinking…")
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(12)
                }
            }
        )
    }
}
