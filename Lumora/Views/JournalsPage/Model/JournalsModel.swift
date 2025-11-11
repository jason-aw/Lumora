//
//  JournalsView.swift
//  Lumora
//
//  Created by Jason Andersen Winfrey on 7/11/2025.
//

import SwiftUI
import Observation

// MARK: - Model
struct JournalEntry: Identifiable, Hashable {
    let id: UUID
    let date: Date
    let snippet: String
    let fullText: String
}

// MARK: - ViewModel
@Observable
final class JournalsViewModel {
    var entries: [JournalEntry] = []
    var expanded: Set<UUID> = []

    init() {
        // Mock data for the last several days to match the screenshot
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        func make(_ iso: String, snippet: String, full: String) -> JournalEntry {
            JournalEntry(
                id: UUID(),
                date: formatter.date(from: iso) ?? Date(),
                snippet: snippet,
                fullText: full
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
        // Sort newest first if desired; screenshot appears ascending per block, but we can keep descending here
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
    
    func addEntry(snippet: String, full: String){
        let newEntry = JournalEntry(id: UUID(), date: Date(), snippet: snippet, fullText: full)
        entries.append(newEntry)
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


#Preview("JournalsView") {
    JournalsView()
}
