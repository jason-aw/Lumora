//
//  JournalsViewModel.swift
//  Lumora
//
//  Created by Jason Andersen Winfrey on 13/11/2025.
//

import Foundation
import Observation

// MARK: - ViewModel
@Observable
final class JournalsViewModel {
    var entries: [JournalEntry] = []
    var expanded: Set<UUID> = []
    var summaryModel: SummaryModel!

    init() {
        // Mock data for the last several days to match the screenshot
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        func make(_ iso: String, snippet: String, full: String) -> JournalEntry {
            JournalEntry(
                id: UUID(),
                date: formatter.date(from: iso) ?? Date(),
                snippet: snippet,
                fullText: full,
                chatLogs: [
                    ChatLog(text: "user chat here", isUser: true),
                    ChatLog(text: "AI response here", isUser: false),
                    ChatLog(text: "more user chat", isUser: true),
                    ChatLog(text: "more AI response", isUser: false)
                ]
            )
        }

        let text = "You’ve talked about your cat today. He died. You sad."
        let full = """
        You’ve talked about your cat today. He died. You sad.
        This is a longer transcript that would appear when expanded or on the detail page.
        """

        entries = [
            make("2025-11-05", snippet: text, full: full),
        ]
        entries.sort { $0.date > $1.date }
    }

    func toggle(_ entry: JournalEntry) {
        if expanded.contains(entry.id) {
            expanded.remove(entry.id)
        } else {
            expanded.insert(entry.id)
        }
    }

    func isExpanded(_ entry: JournalEntry) -> Bool {
        expanded.contains(entry.id)
    }

    /// adds a journal entry by summarizing the full text using the summary model
    func addEntry(chatLogs: [ChatLog]) {
        Task {
            if summaryModel == nil {
                summaryModel = SummaryModel()
            }
            if summaryModel?.chat == nil {
                summaryModel?.startChat()
            }
            let full = chatLogs.map(\.text).joined(separator: "\n")
            let snippet = await summaryModel.sendChat(userInput: "Use option 1: " + full)
            let newEntry = JournalEntry(
                id: UUID(),
                date: Date(),
                snippet: snippet,
                fullText: full,
                chatLogs: chatLogs
            )
            entries.append(newEntry)
        }
    }
}
