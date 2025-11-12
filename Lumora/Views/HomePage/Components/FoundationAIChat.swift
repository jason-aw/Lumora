//
//  FoundationAIChat.swift
//  Lumora
//
//  Created by Jason Andersen Winfrey on 12/11/2025.
//

import Foundation
import FoundationModels

@Observable
class FoundationAIChat {
    private var session: LanguageModelSession!
    
    let systemInstructions = "You are a sleep therapist. Your name is Lumora. Help the user to journal their thoughts which will help them fall asleep, and provide gentle, calming responses. Keep your answers brief and soothing. Your tone should be empathetic and supportive, guiding the user towards relaxation and sleep. Your responses shouldn't be too long, mimicking a human conversational partner. Avoid using lists or bullet points."
    
    init () {
        setup()
    }
    
    func setup() {
        session = LanguageModelSession(instructions: systemInstructions)
    }
    
    func sendChat(userInput: String) async -> String {
        do {
            let response = try await session.respond(to: userInput)
            return response.content
        } catch {
            print("Error: \(error)")
            return ""
        }
    }
    
}
