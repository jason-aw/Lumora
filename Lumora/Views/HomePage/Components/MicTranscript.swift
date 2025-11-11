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
    
    var currSpeech:String = "..."
    var currSound:Float = 1
    var listening:Bool = false
    var audioEngine:AVAudioEngine!
    var speechRecognizer:SFSpeechRecognizer!
    var transcriptRequest:SFSpeechAudioBufferRecognitionRequest!
    var recognitionTask:SFSpeechRecognitionTask!
    
    init(){
        setupTranscript()
    }
    
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
    
    func startListening(){
        
        transcriptRequest = SFSpeechAudioBufferRecognitionRequest()
        transcriptRequest.shouldReportPartialResults = true
        listening = true
        
        let inputNode = audioEngine.inputNode
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.removeTap(onBus: 0)
        
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat, block: { (buffer, when) in
            self.transcriptRequest.append(buffer)
            self.currSound = self.getAudioLevel(buffer: buffer)
        })
        
        audioEngine.prepare()
        try? audioEngine.start()
        
        speechRecognizer.recognitionTask(with: transcriptRequest){ result, error in
            if let result = result {
                Task{
                    self.currSpeech = result.bestTranscription.formattedString
                }
            }
            
            if error != nil || result?.isFinal == true {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                self.transcriptRequest = nil
                self.recognitionTask = nil
            }
            
        }
        
    }
    
    func stopListening(){
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        transcriptRequest.endAudio()
        recognitionTask = nil
        recognitionTask = nil
        listening = false
    }
    
    
    func getAudioLevel(buffer: AVAudioPCMBuffer) -> Float {
            guard let channelData = buffer.floatChannelData else { return 0 }
            let channelDataArray = Array(UnsafeBufferPointer(start: channelData[0], count: Int(buffer.frameLength)))
            let rms = sqrt(channelDataArray.map {$0 * $0}.reduce(0, +)) / Float(buffer.frameLength) + Float.ulpOfOne
            let level = 20 * log10(rms)
            return max(level + 100, 0)/10
      
    }
}

