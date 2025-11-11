//
//  MicTranscript.swift
//  Lumora
//
//  Created by Kenneth Gabriel Libarnes on 9/11/2025.
//

import Foundation
import AVFoundation
import Speech

@Observable
class MicTranscript {
    
    var currSpeech: String = "..."
    var currSound: Double = 1
    var listening: Bool = false
    
    var audioEngine: AVAudioEngine!
    var speechRecognizer: SFSpeechRecognizer!
    var transcriptRequest: SFSpeechAudioBufferRecognitionRequest!
    
    init() {
        setupTranscript()
    }
    
    func setupTranscript() {
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
    
    func startListening() {
        transcriptRequest = SFSpeechAudioBufferRecognitionRequest()
        transcriptRequest.shouldReportPartialResults = true
        listening = true
        
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.removeTap(onBus: 0)
        
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.transcriptRequest.append(buffer)
            let rawLevel = self.getAudioLevel(buffer: buffer)
            
            // Publish the raw audio level
            Task { @MainActor in
                self.currSound = rawLevel
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
                self.stopListening()
            }
        }
        
    }
    
    func stopListening() {
        self.audioEngine.stop()
        self.audioEngine.inputNode.removeTap(onBus: 0)
        self.transcriptRequest = nil
        listening = false
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
