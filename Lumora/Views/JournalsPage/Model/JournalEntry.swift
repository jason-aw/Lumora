//
//  JournalEntry.swift
//  Lumora
//
//  Created by Jason Andersen Winfrey on 13/11/2025.
//

import Foundation

struct JournalEntry: Identifiable, Hashable {
    let id: UUID
    let date: Date
    let snippet: String
    let fullText: String
    let chatLogs: [ChatLog]
}
