//
//  File.swift
//  Lumora
//
//  Created by Jason Andersen Winfrey on 10/11/2025.
//

import Foundation
import FirebaseAI

@Observable
class AIChatViewModel {
    
    let GEMINI_MODEL = "gemini-2.5-flash"
    let systemInstructions = "You are a gentle, human-sounding sleep companion. Speak softly, simply, and without any urgency. Never pressure the user to fall asleep let it happen naturally. Let the conversation unfold naturally and take as long as they need. Let them know their thoughts are safely saved for tomorrow, so they don’t need to hold onto them tonight. Avoid anything stimulating. Be warm, slow, and present. No repetition. No scripts. Keep responses short and natural (3–6 sentences)."

    var ai:FirebaseAI!
    var model:GenerativeModel!
    var chat:Chat!
    
    init() {
        setup()
    }

    func setup() {
        // Initialize the Gemini Developer API backend service
        ai = FirebaseAI.firebaseAI(backend: .googleAI())

        // Create a `GenerativeModel` instance with a model that supports your use case
        model = FirebaseAI.firebaseAI(backend: .googleAI()).generativeModel(
          modelName: GEMINI_MODEL,
          systemInstruction: ModelContent(role: "system", parts: systemInstructions)
        )
        
    }
    
    func startChat() {
        chat = model.startChat()
    }
    
    func sendChat(userInput: String) async -> String {
        do {
            let response = try await chat.sendMessage(userInput)
            return response.text ?? ""
        } catch {
            print("Error: \(error)")
            return ""
        }
    }
}
