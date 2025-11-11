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
    let systemInstructions = "You are a sleep therapist. Your name is Lumora. Help the user to journal their thoughts which will help them fall asleep, and provide gentle, calming responses. Keep your answers brief and soothing. Your tone should be empathetic and supportive, guiding the user towards relaxation and sleep. Your responses shouldn't be too long, mimicking a human conversational partner. Avoid using lists or bullet points."

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
