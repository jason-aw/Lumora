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
    @State private var showTranscript: Bool = true
    @State private var startingOffset: CGFloat = UIScreen.main.bounds.height * 0.85
    @State private var currentOffset:CGFloat = 0
    @State private var endOffset:CGFloat = 0
    
    @Environment(\.dismiss) private var dismiss
    @Environment(JournalsViewModel.self) var model

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
    
    // MARK: - AI BLOB
    var body: some View {
        ZStack {
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
            }
 
            // MARK: - TRANSCRIPT PULL UP
            VStack {
                TranscriptPullUp(transcriptMic: transcriptMic)
                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                    .clipShape(RoundedRectangle(cornerRadius: 32))
                    .offset(y:startingOffset)
                    .offset(y:currentOffset)
                    .offset(y:endOffset)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                withAnimation(.spring()) {
                                    currentOffset = value.translation.height
                                }
                            }
                            .onEnded { value in
                                withAnimation(.spring()) {
                                    if currentOffset < -150 {
                                        endOffset = -startingOffset * 0.85
                                    } else if endOffset != 0 && currentOffset > 150 {
                                        endOffset = 0
                                    }
                                    currentOffset = 0
                                }
                            }
                    )
            }   
        }
        // MARK: - Hidden Navigation Bar
        .toolbar(.hidden, for: .tabBar)
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
