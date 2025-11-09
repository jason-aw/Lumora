//
//  JournalsView.swift
//  Lumora
//
//  Created by Jason Andersen Winfrey on 7/11/2025.
//

import SwiftUI

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
            make("2025-11-06", snippet: text, full: full),
            make("2025-11-07", snippet: text, full: full),
            make("2025-11-09", snippet: text, full: full),
            make("2025-11-11", snippet: text, full: full),
            make("2025-11-12", snippet: text, full: full),
            make("2025-11-14", snippet: text, full: full),
            make("2025-11-15", snippet: text, full: full)
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
}

// MARK: - View
struct JournalsView: View {
    @State private var model = JournalsViewModel()
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
                            JournalCard(
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
            .background(Color("backgroundColor").ignoresSafeArea())
            .navigationDestination(for: JournalEntry.self) { entry in
                JournalTranscriptViewWrapper(entry: entry)
            }
        }
    }

    // MARK: - Card
    @ViewBuilder
    private func JournalCard(entry: JournalEntry,
                             isExpanded: Bool,
                             onToggle: @escaping () -> Void,
                             onOpen: @escaping () -> Void) -> some View {
        Button(action: onOpen) {
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(format(date: entry.date))
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundColor(.white)

                        Text(entry.snippet)
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(.white.opacity(0.75))
                            .lineLimit(isExpanded ? nil : 2)
                            .multilineTextAlignment(.leading)
                    }

                    Spacer()

                    // Chevron to toggle expansion without navigating
                    Button(action: onToggle) {
                        Image(systemName: "chevron.down")
                            .font(.system(size: 18, weight: .semibold))
                            .rotationEffect(.degrees(isExpanded ? 180 : 0))
                            .foregroundColor(.white.opacity(0.6))
                            .padding(6)
                    }
                    .buttonStyle(.plain)
                }

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

    // MARK: - Date formatting
    private func format(date: Date) -> String {
        let df = DateFormatter()
        df.locale = Locale(identifier: "en_GB")
        df.setLocalizedDateFormatFromTemplate("d MMM yyyy")
        return df.string(from: date)
    }
}

// MARK: - Detail wrapper that feeds the selected entry to your existing view
private struct JournalTranscriptViewWrapper: View {
    let entry: JournalEntry

    var body: some View {
        JournalTranscriptView()
            .navigationTitle(formattedTitle(entry.date))
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color("backgroundColor"), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .background(Color("backgroundColor").ignoresSafeArea())
    }

    private func formattedTitle(_ date: Date) -> String {
        let df = DateFormatter()
        df.setLocalizedDateFormatFromTemplate("d MMM yyyy")
        return df.string(from: date)
    }
}

#Preview {
    JournalsView()
}
