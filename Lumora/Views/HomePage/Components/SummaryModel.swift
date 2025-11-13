//
//  File.swift
//  Lumora
//
//  Created by Jason Andersen Winfrey on 10/11/2025.
//

import Foundation
import Observation
import FirebaseAI

@Observable
class SummaryModel {
    let GEMINI_MODEL = "gemini-2.5-flash"
    let systemInstructions = "Depending on the given instructions, be one of these 3 tasks: 1) Summarize the following conversation into its three most important points. Use short, clear sentences, and limit the summary to a maximum of two short and concise sentences total. Focus only on the key ideas and feelings or decisions made in the conversation. Make sure it reads like sentences, don't use lists or dot points. Instead of saying the speaker, say it in a personal way by referring to them as 'You', imagine you were the therapist they were talking to. 2) Track the general mood of the past conversations of the user. What are the main emotions or feelings expressed by the person? Are there any recurring themes or motifs? Write only a short sentence with 10-12 words of your findings to be put in a 'Mood Trend' section for the user to gain insight, don't add a title, respond with just the sentence. 3) Create bullet points of the most important things the user has talked about and how they said they were feeling. Make it short and concise and useful information that the user can use to gain insight on their mood and their sleep. Keep the sentences short and concise, no more than 5 bullet points."

    // Make these optional and initialize lazily to avoid touching Firebase before configuration
    var ai: FirebaseAI?
    var model: GenerativeModel?
    var chat: Chat?

    init() {
        // Do not call setup() here; we will set up lazily on first use
    }

    private func setupIfNeeded() {
        if model != nil { return }
        // Initialize the Gemini Developer API backend service
        let ai = FirebaseAI.firebaseAI(backend: .googleAI())
        self.ai = ai

        // Create a `GenerativeModel` instance
        self.model = ai.generativeModel(
            modelName: GEMINI_MODEL,
            systemInstruction: ModelContent(role: "system", parts: systemInstructions)
        )
    }
    
    func startChat() {
        setupIfNeeded()
        guard let model else { return }
        self.chat = model.startChat()
    }
    
    func sendChat(userInput: String) async -> String {
        // Ensure chat exists; if not, start it now
        if chat == nil {
            startChat()
        }
        guard let chat else { return "" }
        do {
            let response = try await chat.sendMessage(userInput)
            return response.text ?? ""
        } catch {
            print("Error: \(error)")
            return ""
        }
    }
}
