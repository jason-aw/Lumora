//
//  JournalsCardView.swift
//  Lumora
//
//  Created by Emily Heng on 10/11/2025.
//

import SwiftUI

// MARK: - JOURNAL CARD VIEW
struct JournalCardView: View {
    let entry: JournalEntry
    let isExpanded: Bool
    let onToggle: () -> Void
    let onOpen: () -> Void

    // Card styling
    private let cardBackground = Color(.systemGray5).opacity(0.25)
    private let cardStroke = Color.white.opacity(0.06)
    private let cardShadow = Color.black.opacity(0.35)

    var body: some View {
        Button(action: onOpen) {
            VStack(alignment: .leading, spacing: 10) {
                
                //Date, snippet, and expand button TOP
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(entry.date.formattedAsJournal())
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundColor(.white)

                        Text(entry.snippet)
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(.white.opacity(0.75))
                            .lineLimit(isExpanded ? nil : 2)
                            .multilineTextAlignment(.leading)
                    }

                    Spacer()

                    //EXPAND and Collaspe
                    Button(action: onToggle) {
                        Image(systemName: "chevron.down")
                            .rotationEffect(.degrees(isExpanded ? 180 : 0))
                            .foregroundColor(.white.opacity(0.6))
                            .padding(6)
                    }
                    .buttonStyle(.plain)
                }
                
                // Expanded Section showing full text
                if isExpanded {
                    Divider().background(Color.white.opacity(0.08))
                    Text(entry.fullText)
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.leading)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .stroke(cardStroke, lineWidth: 1)
                    )
                    .shadow(color: cardShadow, radius: 12, x: 0, y: 8)
            )
        }
        .buttonStyle(.plain)
    }
}





