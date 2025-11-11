//
//  MicTranscript.swift
//  Lumora
//
//  Created by Kenneth Gabriel Libarnes on 9/11/2025.
//

import Foundation
import AVFoundation
import Speech
import Observation;


@Observable
class MicTranscript {
    
    var chat: [AiTurn] = [] //array of finished transcripts
    var currSpeech:String = "..."
    var currSound:Double = 1
    var listening:Bool = false
    
    // Audio Kit Objects
    var audioEngine:AVAudioEngine!
    var speechRecognizer:SFSpeechRecognizer!
    var transcriptRequest:SFSpeechAudioBufferRecognitionRequest!
    var recognitionTask:SFSpeechRecognitionTask!
    
    init() {
        setupTranscript()
    }
    
    // MARK: - Ask for permission for speech recognition

    func setupTranscript(){
        audioEngine = AVAudioEngine()
        speechRecognizer = SFSpeechRecognizer()
        
        SFSpeechRecognizer.requestAuthorization { (status) in
            DispatchQueue.main.async {
                switch status {
                case .authorized:
                    print("Enabled")
                case .denied, .notDetermined, .restricted:
                    print("Not enabled")
                @unknown default:
                    fatalError("It's broken")
                }
            }
        }
    }
    
    // MARK: - Start Listening & Stop Listening
    
    func startListening(){
        
        transcriptRequest = SFSpeechAudioBufferRecognitionRequest()
        transcriptRequest.shouldReportPartialResults = true
        listening = true
        
        let inputNode = audioEngine.inputNode
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.removeTap(onBus: 0)
        
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat, block: { (buffer, when) in
            self.transcriptRequest.append(buffer)
            let rawLevel = self.getAudioLevel(buffer: buffer)
            
            // Publish the raw audio level
            Task { @MainActor in
                self.currSound = rawLevel
            }
        })
        
        audioEngine.prepare()
        try? audioEngine.start()
        
        speechRecognizer.recognitionTask(with: transcriptRequest) { [weak self] result, error in
            guard let self else { return }
            
            if let result = result {
                Task { @MainActor in
                    self.currSpeech = result.bestTranscription.formattedString
                }
            }
            
            // when the sentence is final, save it and let the bot answer
            if result?.isFinal == true,
               let final = result?.bestTranscription.formattedString,
               !final.isEmpty {
                Task { @MainActor in
                    self.chat.append(AiTurn(text: final, isUser: true))
                    self.currSpeech = "..."
                    self.mockBotReply(to: final)
                }
            }
            
            if error != nil || result?.isFinal == true {
                self.stopListening()
            }
        }
        
    }
    
    func stopListening() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        transcriptRequest = nil
        recognitionTask = nil
        listening = false
    }
    
    // MARK: - Volume Meter for Blob
    
    func getAudioLevel(buffer: AVAudioPCMBuffer) -> Float {
            guard let channelData = buffer.floatChannelData else { return 0 }
            let channelDataArray = Array(UnsafeBufferPointer(start: channelData[0], count: Int(buffer.frameLength)))
            let rms = sqrt(channelDataArray.map {$0 * $0}.reduce(0, +)) / Float(buffer.frameLength) + Float.ulpOfOne
            let level = 20 * log10(rms)
            return max(level + 100, 0)/10
      
    }

    /// returns a normalized audio level (0.0 - 1.0) from the given buffer
    func getAudioLevel(buffer: AVAudioPCMBuffer) -> Double {
        guard let channelData = buffer.floatChannelData else { return 0 }
        let channelDataArray = Array(UnsafeBufferPointer(start: channelData[0], count: Int(buffer.frameLength)))
        let rms = sqrt(channelDataArray.map { $0 * $0 }.reduce(0, +)) / Float(buffer.frameLength) + Float.ulpOfOne
        let level = 20 * log10(rms)
        return Double(max(level + 100, 0) / 100)
    }
    
}

// MARK: - PLACEHOLDER FOR AI
extension MicTranscript {
    func mockBotReply(to userText: String) {
        let answers = [ "this is a placeholder test response. this is a placeholder test response. this is a placeholder test response. this is a placeholder test response. this is a placeholder test response."]
        
        let reply = answers.randomElement()!
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            self.chat.append(AiTurn(text: reply, isUser: false))
        }
        //Append new AiTurn with isUser: false
    }
}



