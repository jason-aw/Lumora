//
//  JournalTranscriptView.swift
//  Lumora
//
//  Created by Jason Andersen Winfrey on 7/11/2025.
//
import SwiftUI

//
struct JournalTranscriptView: View {
    let entry: JournalEntry

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(entry.snippet)
                    .font(.headline)
                    .foregroundColor(.white)

                Text(entry.fullText)
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding()
        }
        .background(Color("backgroundColor").ignoresSafeArea())
    }
}

struct JournalTranscriptViewWrapper: View {
    let entry: JournalEntry

    var body: some View {
        JournalTranscriptView(entry: entry)
            .navigationTitle(formattedTitle(entry.date))
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color("backgroundColor"), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
    }

    private func formattedTitle(_ date: Date) -> String {
        let df = DateFormatter()
        df.setLocalizedDateFormatFromTemplate("d MMM yyyy")
        df.locale = Locale(identifier: "en_GB")
        return df.string(from: date)
    }
}


