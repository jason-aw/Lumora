//
//  JournalTranscriptView.swift
//  Lumora
//
//  Created by Jason Andersen Winfrey on 7/11/2025.
//
import SwiftUI

// MARK: - JOURNAL TRANSCRIPT VIEW
struct JournalTranscriptView: View {
    let entry: JournalEntry
    
    private var turns: [AiTurn] {
        entry.fullText
            .components(separatedBy: .newlines)
            .map { AiTurn(text: $0, isUser: false) }
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 8) {
                    Color.clear.frame(height: 52) // spacing buffer
                    ForEach(turns) { turn in
                        TranscriptMessageRow(turn: turn)
                    }
                }
                .padding(.top, 100) //To push the first text below the Transcript title
                .padding(.horizontal, 24)
            }
            .background(Color("backgroundColor"))
            .ignoresSafeArea()
            
            // TRANSCRIPT TITLE
            VStack(spacing: 0) {
                Text("Transcript")
                    .font(.title2.weight(.semibold))
                    .foregroundColor(.white.opacity(0.8))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
            }
            .background(Color("backgroundColor"))
        }
    }
}

// MARK: - TRANSCRIPT WRAPPER
struct JournalTranscriptViewWrapper: View {   // ← now a true top-level type
    let entry: JournalEntry
    
    var body: some View {
        JournalTranscriptView(entry: entry)
            .navigationTitle(entry.date.formattedAsJournal())
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color("backgroundColor"), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
    }
    
}
