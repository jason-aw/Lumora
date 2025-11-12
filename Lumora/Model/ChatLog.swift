//
//  ChatLog.swift
//  Lumora
//
//  Created by Jason Andersen Winfrey on 13/11/2025.
//

import Foundation

/// Data Model for transcript
struct ChatLog: Identifiable, Hashable {
    let id = UUID()
    let text: String
    let isUser: Bool
}
