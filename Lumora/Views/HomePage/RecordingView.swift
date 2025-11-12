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
    @State private var startingOffset: CGFloat = UIScreen.main.bounds.height * 0.85
    @State private var currentOffset:CGFloat = 0
    @State private var endOffset:CGFloat = 0
    @State private var chatLogs: [ChatLog] = []
    
    @Environment(\.dismiss) private var dismiss
    @Environment(JournalsViewModel.self) var model
//    @Environment(AIChatViewModel.self) var aiChat
    @State private var aiChat = AIChatViewModel()
    
    let synthesizer = AVSpeechSynthesizer()

    @State private var loading: Bool = false
    @State private var aiResponse: String = ""
    @State private var silenceTask: Task<Void, Never>?
    
    let silenceThreshold: Double = 0.33
    let silenceDuration: TimeInterval = 1.5

    private func getAIResponse(userMessage: String) async {
        if self.loading == true {
            return
        }

        await MainActor.run { self.loading = true }
        print("Getting AI response for message: \(userMessage)")
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
            print("Starting silence task")
            do {
                try await Task.sleep(nanoseconds: UInt64(silenceDuration * 1_000_000_000))
                print("Silence duration passed")
            } catch {
                print("Silence task cancelled")
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

            print("Silence detected, processing speech: \(transcriptMic.currSpeech)")

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
                
                Button("toggle") {
                    if transcriptMic.listening {
                        transcriptMic.stopListening()
                    } else {
                        transcriptMic.startListening()
                    }
                }
                .padding()
                .background(.blue)

            }
 
            // MARK: - TRANSCRIPT PULL UP
            VStack {
                TranscriptPullUp(chatLogs: $chatLogs, transcriptMic: transcriptMic)
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
            transcriptMic.startListening()
        }
        .onChange(of: transcriptMic.currSound) { newVolume in
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
