//
//  MicTranscript.swift
//  Lumora
//
//  Created by Kenneth Gabriel Libarnes on 9/11/2025.
//

import Foundation
import AVFoundation
import Speech
import Observation

@Observable
final class MicTranscript {
    
    var currSpeech: String = "..."
    var currSound: Double = 1
    var listening: Bool = false
    var loading: Bool = false
    
    var audioEngine: AVAudioEngine!
    var speechRecognizer: SFSpeechRecognizer!
    var transcriptRequest: SFSpeechAudioBufferRecognitionRequest!
    var silenceTimer: Timer?
    var aiChat: AIChatViewModel?
    
    // Tweak these based on your environment and microphone
    let silenceThreshold: Double = 1.0
    let silenceDuration: TimeInterval = 1.0
    
    init() {
        setupTranscript()
    }
    
    func setupTranscript() {
        audioEngine = AVAudioEngine()
        speechRecognizer = SFSpeechRecognizer()
        aiChat = AIChatViewModel()
        
        SFSpeechRecognizer.requestAuthorization { (status) in
            DispatchQueue.main.async {
                switch status {
                case .authorized:
                    print("Enabled")
                    self.aiChat?.startChat()
                case .denied, .notDetermined, .restricted:
                    print("Not enabled")
                @unknown default:
                    fatalError("It's broken")
                }
            }
        }
    }
    
    func startListening() {
        transcriptRequest = SFSpeechAudioBufferRecognitionRequest()
        transcriptRequest.shouldReportPartialResults = true
        listening = true
        
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.removeTap(onBus: 0)
        
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.transcriptRequest.append(buffer)
            let rawLevel = self.getAudioLevel(buffer: buffer) // may be outside 0...1
            
            // Publish to UI on the main actor so Observation/SwiftUI see every change
            Task { @MainActor in
                self.currSound = rawLevel
            }
            
            // Silence detection uses rawLevel; adjust if desired
            if rawLevel > self.silenceThreshold {
                self.resetSilenceTimer()
            }
        }
        
        audioEngine.prepare()
        try? audioEngine.start()
        
        speechRecognizer.recognitionTask(with: transcriptRequest) { result, error in
            if let result = result {
                Task { @MainActor in
                    self.currSpeech = result.bestTranscription.formattedString
                }
            }
            
            if error != nil || result?.isFinal == true {
                self.finishListeningAndSendToAI()
            }
        }
        
        // Start silence timer when listening starts
        resetSilenceTimer()
    }
    
    func stopListening() {
        self.audioEngine.stop()
        self.audioEngine.inputNode.removeTap(onBus: 0)
        self.transcriptRequest = nil
        listening = false
        invalidateSilenceTimer()
    }
    
    private func resetSilenceTimer() {
        invalidateSilenceTimer()
        silenceTimer = Timer.scheduledTimer(withTimeInterval: silenceDuration, repeats: false) { [weak self] _ in
//            self?.onSilenceDetected()
        }
    }
    
    private func invalidateSilenceTimer() {
        silenceTimer?.invalidate()
        silenceTimer = nil
    }
    
    private func onSilenceDetected() {
        // Consider the user done talking
        finishListeningAndSendToAI()
    }
    
    private func finishListeningAndSendToAI() {
        stopListening()
        // Only send to AI if not already loading and have some speech
//        guard true, !loading, !currSpeech.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
//        
//        loading = true
//        Task { @MainActor in
//            let response = await aiChat?.sendChat(userInput: currSpeech) ?? ""
//            self.currSpeech = response
//            self.loading = false
//        }
    }
    
    func getAudioLevel(buffer: AVAudioPCMBuffer) -> Double {
        guard let channelData = buffer.floatChannelData else { return 0 }
        let channelDataArray = Array(UnsafeBufferPointer(start: channelData[0], count: Int(buffer.frameLength)))
        let rms = sqrt(channelDataArray.map { $0 * $0 }.reduce(0, +)) / Float(buffer.frameLength) + Float.ulpOfOne
        let level = 20 * log10(rms)
        return Double(max(level + 100, 0) / 100)
    }
}
