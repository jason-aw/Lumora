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
    
    @State private var loading: Bool = false
    @State private var aiResponse: String = ""
    @State private var silenceTask: Task<Void, Never>?
    
    private var aiChat:AIChatViewModel = AIChatViewModel()
    
    let silenceThreshold: Double = 0.2
    let silenceDuration: TimeInterval = 3.0
    
    private func getAIResponse() async {
        guard self.loading == false else { return }
        let userMessage = transcriptMic.currSpeech.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !userMessage.isEmpty else { return }
        
        self.loading = true
        let response = await aiChat.sendChat(userInput: userMessage)
        self.aiResponse = response
        self.loading = false
    }
    
    private func resetSilenceTask() {
        self.cancelSilenceTask()
        
        self.silenceTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: UInt64(silenceDuration * 1_000_000_000))
            
            await self.getAIResponse()
        }
    }
    
    private func cancelSilenceTask() {
        self.silenceTask?.cancel()
        self.silenceTask = nil
    }
        
    
    var body: some View {
        VStack(spacing: 24) {
            // Live value
            Text(String(format: "Volume: %.2f", transcriptMic.currSound))
                .font(.system(.body, design: .monospaced))
                .foregroundStyle(.secondary)
            
            // Bubble under test
            FinalBubbleView(size: 234, blur: 12, animationSpeed: 10.0, volume: $transcriptMic.currSound)
            
//            // TEMP: Manual control to simulate volume 0...1
//            VStack(alignment: .leading, spacing: 8) {
//                Text("Test Volume")
//                    .foregroundStyle(.secondary)
//                Slider(value: $transcriptMic.currSound, in: 0...1)
//            }
//            .padding(.horizontal)
            
            // Speech text
            Text(transcriptMic.currSpeech)
                .padding(.top, 8)
            
            Text("AI Response:")
                .font(.headline)
                .padding(.top, 16)
            Text(aiResponse)

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
        .onAppear {
            aiChat.startChat()
        }
        .onChange(of: transcriptMic.currSound) { newVolume, _ in
            if newVolume > self.silenceThreshold {
                self.resetSilenceTask()
            }
        }
        .onDisappear {
            self.cancelSilenceTask()
        }
        .padding()
        .overlay(
            Group {
                if self.loading {
                    ProgressView("Thinking…")
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(12)
                }
            }
        )
    }
}
