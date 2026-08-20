//
//  JournalsView.swift
//  Lumora
//
//  Created by Jason Andersen Winfrey on 7/11/2025.
//

import SwiftUI
import Observation

extension Date {
    func formattedAsJournal() -> String {
        let df = DateFormatter()
        df.locale = Locale(identifier: "en_GB")
        df.setLocalizedDateFormatFromTemplate("d MMM yyyy")
        return df.string(from: self)
    }
}

// MARK: - View
struct JournalsView: View {
    @Environment(JournalsViewModel.self) var model
    @State private var path = NavigationPath()

    private let cardBackground = Color(.systemGray5).opacity(0.25)
    private let cardStroke = Color.white.opacity(0.06)
    private let cardShadow = Color.black.opacity(0.35)

    var body: some View {
        NavigationStack(path: $path) {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text("Journal")
                        .font(.system(size: 44, weight: .bold, design: .default))
                        .foregroundColor(.white)
                        .padding(.top, 8)
                        .padding(.horizontal, 24)

                    VStack(spacing: 20) {
                        ForEach(model.entries) { entry in
                            JournalCardView(
                                entry: entry,
                                isExpanded: model.isExpanded(entry),
                                onToggle: { model.toggle(entry) },
                                onOpen: { path.append(entry) }
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 32)
                }
            }
            .frame(maxWidth: .infinity)
            .background(Color("backgroundColor").ignoresSafeArea())
            .navigationDestination(for: JournalEntry.self) { entry in
                JournalTranscriptViewWrapper(entry: entry)
            }
        }
    }
}

