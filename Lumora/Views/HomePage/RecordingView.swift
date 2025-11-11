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
        VStack {
            Text(String(transcriptMic.currSound))
            
            BlobView(volume: $transcriptMic.currSound)
            
            Text(transcriptMic.currSpeech)
            
            Button ("Toggle Recording") {
                if transcriptMic.audioEngine.isRunning {
                    transcriptMic.stopListening()
                } else {
                    transcriptMic.startListening()
                }
            }
            .background(.red)
        }
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
