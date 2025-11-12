//
//  File.swift
//  Lumora
//
//  Created by Jason Andersen Winfrey on 10/11/2025.
//

import Foundation
import FirebaseAI

@Observable
class SummaryModel {
    
    let GEMINI_MODEL = "gemini-2.5-flash"
    let systemInstructions = "Summarize the following conversation into its three most important points. Use short, clear sentences, and limit the summary to a maximum of two short and concise sentences total. Focus only on the key ideas and feelings or decisions made in the conversation. Make sure it reads like sentences, don't use lists or dot points. Instead of saying the speaker, say it in a personal way by referring to them as 'You', imagine you were the therapist they were talking to"
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
