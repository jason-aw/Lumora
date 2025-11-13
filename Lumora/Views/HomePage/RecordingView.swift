//
//  RecordingView.swift
//  Lumora
//
//  Created by Jason Andersen Winfrey on 7/11/2025.
//

import SwiftUI
import AVFAudio
import AVFoundation

struct RecordingView: View {
    @State private var transcriptMic = MicTranscript()
    @State private var showTranscript: Bool = true
    @State private var chatLogs: [ChatLog] = []
    
    @Environment(\.dismiss) private var dismiss
    @Environment(JournalsViewModel.self) var model
    @State private var aiChat = AIChatViewModel()
    @State private var foundationChat = FoundationAIChat()
    
    let synthesizer = AVSpeechSynthesizer()

    @State private var loading: Bool = false
    @State private var aiResponse: String = ""
    @State private var silenceTask: Task<Void, Never>?
    
    // Bottom sheet positioning
    @State private var sheetOffset: CGFloat = 0 // current Y offset (animated)
    @State private var dragOffset: CGFloat = 0  // transient drag delta

    let silenceThreshold: Double = 0.33
    let silenceDuration: TimeInterval = 1.5

    let debug = true
    
    private func getAIResponse(userMessage: String) async {
        if aiChat.chat == nil {
            aiChat.startChat()
        }

        await MainActor.run { self.loading = true }
//        print("Getting AI response for message: \(userMessage)")
//        let response = await aiChat.sendChat(userInput: userMessage)
        let response = await aiChat.sendChat(userInput: userMessage)
        await MainActor.run {
            self.aiResponse = response
            self.loading = false
        }
    }
    
    private func startSilenceTask() {
//        print("cancel silence task")
        guard silenceTask == nil else { return }

        self.silenceTask = Task { @MainActor in
//            print("Starting silence task")
            do {
                try await Task.sleep(nanoseconds: UInt64(silenceDuration * 1_000_000_000))
//                print("Silence duration passed")
            } catch {
//                print("Silence task cancelled")
                return
            }
            

            let userMessage = transcriptMic.currSpeech.trimmingCharacters(in: .whitespacesAndNewlines)
            if userMessage.isEmpty {
                return
            }
            let components = userMessage.components(separatedBy: .whitespacesAndNewlines)
            if components.count <= 3 {
                return
            }

//            print("Silence detected, processing speech: \(transcriptMic.currSpeech)")

            chatLogs.append(ChatLog(text: transcriptMic.currSpeech, isUser: true))
            transcriptMic.stopListening()
            await self.getAIResponse(userMessage: userMessage)
            
            await MainActor.run {
                guard aiResponse != "" else { return }
                chatLogs.append(ChatLog(text: aiResponse, isUser: false))

                // let AI speak
                let uttterance = AVSpeechUtterance(string: aiResponse)
                uttterance.voice = AVSpeechSynthesisVoice(language: "en-US")
                synthesizer.speak(uttterance)
            }

            transcriptMic.startListening()

        }
    }
    
    private func cancelSilenceTask() {
        self.silenceTask?.cancel()
        self.silenceTask = nil
    }

    var body: some View {
        GeometryReader { geometry in
            // Compute sheet metrics
            let sheetHeight = geometry.size.height * 0.85
            let openOffset = geometry.size.height - sheetHeight
            // Closed shows a grabber area (~120pt) above bottom
            let closedPeek: CGFloat = geometry.size.height * 0.15
            let closedOffset = geometry.size.height - closedPeek

            ZStack {
                // Blob and controls
                VStack(spacing: 24) {
                    Text(String(format: "Volume: %.2f", transcriptMic.currSound))
                        .font(.system(.body, design: .monospaced))
                        .foregroundStyle(.secondary)
                    
                    FinalBubbleView(size: 234, blur: 12, animationSpeed: 10.0, volume: $transcriptMic.currSound)
                    
    //            // TEMP: Manual control to simulate volume 0...1
    //            VStack(alignment: .leading, spacing: 8) {
    //                Text("Test Volume")
    //                    .foregroundStyle(.secondary)
    //                Slider(value: $transcriptMic.currSound, in: 0...1)
    //            }
    //            .padding(.horizontal)
                
//                // Speech text
//                Text(transcriptMic.currSpeech)
//                    .padding(.top, 8)
                
//                Text("AI Response:")
//                    .font(.headline)
//                    .padding(.top, 16)
//                Text(aiResponse)
                    
                    HStack(spacing: 100) {
                        // toggle mute button
                        GlassButton(systemImage: transcriptMic.listening ? "mic" : "mic.slash") {
                            if transcriptMic.listening {
                                transcriptMic.stopListening()
                            } else {
                                transcriptMic.startListening()
                            }
                        }
                        
                        // close button, stop recording and save transcript
                        GlassButton(systemImage: "xmark") {
                            transcriptMic.stopListening()
                            cancelSilenceTask()
                            
                            model.addEntry(chatLogs: chatLogs)
                            
                            dismiss()
                        }
                    }
                }

                // TRANSCRIPT PULL UP
                VStack {
                    TranscriptPullUp(chatLogs: $chatLogs, transcriptMic: transcriptMic)
                        .frame(width: geometry.size.width, height: sheetHeight)
                        .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
                        .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: -4)
                }
                // Positioning: base at openOffset, then apply current sheetOffset + dragOffset
                .offset(y: openOffset + sheetOffset + dragOffset)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            // Apply drag delta, but we clamp only on end for elasticity feel
                            dragOffset = value.translation.height
                        }
                        .onEnded { value in
                            // Proposed new resting offset
                            let proposed = sheetOffset + value.translation.height
                            // Snap to nearest state: open or closed
                            let mid = (closedOffset - openOffset) / 2
                            let snapped: CGFloat = (proposed > mid) ? closedOffset - openOffset : 0
                            
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                                sheetOffset = min(max(snapped, 0), closedOffset - openOffset)
                                dragOffset = 0
                            }
                        }
                )
            }
            .onAppear {
                // Initialize to closed position
                sheetOffset = closedOffset - openOffset
                transcriptMic.startListening()
            }
            .onChange(of: transcriptMic.currSound) { newVolume, _ in
                if newVolume > self.silenceThreshold {
                    self.cancelSilenceTask()
                } else {
                    self.startSilenceTask()
                }
            }
            .onDisappear {
                transcriptMic.stopListening()
                self.cancelSilenceTask()
            }
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
        .toolbar(.hidden, for: .tabBar)
    }
}

#Preview("RecordingView") {
    RecordingView()
}
