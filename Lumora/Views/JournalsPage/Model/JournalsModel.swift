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
            make("2025-11-06", snippet: text, full: full),
            make("2025-11-07", snippet: text, full: full),
            make("2025-11-09", snippet: text, full: full),
            make("2025-11-11", snippet: text, full: full),
            make("2025-11-12", snippet: text, full: full),
            make("2025-11-14", snippet: text, full: full),
            make("2025-11-15", snippet: text, full: full)
        ]
        // Sort newest first
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

    func upsert(_ entry: JournalEntry) {
        if let idx = entries.firstIndex(where: { $0.id == entry.id }) {
            entries[idx] = entry
        } else {
            entries.insert(entry, at: 0)
        }
        entries.sort { $0.date > $1.date }
    }
}

// MARK: - View
struct JournalsView: View {
    @State private var model = JournalsViewModel()

    // Sheet state
    @State private var showCompose = false
    @State private var editingEntry: JournalEntry? = nil
    @State private var creatingNew = false

    private let cardBackground = Color(.systemGray5).opacity(0.25)
    private let cardStroke = Color.white.opacity(0.06)
    private let cardShadow = Color.black.opacity(0.35)

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    header

                    VStack(spacing: 20) {
                        ForEach(model.entries) { entry in
                            JournalCardView(
                                entry: entry,
                                isExpanded: model.isExpanded(entry),
                                onToggle: { model.toggle(entry) },
                                onOpen: {
                                    editingEntry = entry
                                    creatingNew = false
                                    showCompose = true
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 32)
                }
            }
            .background(Color("backgroundColor").ignoresSafeArea())
            .sheet(isPresented: $showCompose) {
                composeSheetView()
                    .background(Color("backgroundColor").ignoresSafeArea())
            }
        }
    }
<<<<<<< HEAD:Lumora/Views/JournalsPage/JournalsView.swift

    private var header: some View {
        HStack {
            Text("Journal")
                .font(.system(size: 44, weight: .bold, design: .default))
                .foregroundColor(.white)
            Spacer()
            Button {
                // Create new
                editingEntry = nil
                creatingNew = true
                showCompose = true
            } label: {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 26, weight: .semibold))
                    .foregroundStyle(.white)
                    .symbolRenderingMode(.hierarchical)
                    .accessibilityLabel("New Journal")
            }
            .buttonStyle(.plain)
        }
        .padding(.top, 8)
        .padding(.horizontal, 24)
    }

    // MARK: - Compose sheet content
    @ViewBuilder
    private func composeSheetView() -> some View {
        if let entry = editingEntry {
            // Edit existing
            JournalComposeView(
                entry: entry,
                onSave: { updated in
                    model.upsert(updated)
                    showCompose = false
                },
                onCancel: { showCompose = false }
            )
        } else {
            // Create new
            JournalComposeView(
                onSave: { newEntry in
                    model.upsert(newEntry)
                    showCompose = false
                },
                onCancel: { showCompose = false }
            )
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
                            .accessibilityLabel(isExpanded ? "Collapse entry" : "Expand entry")
                            .accessibilityValue(isExpanded ? "Expanded" : "Collapsed")
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

#Preview {
=======
}


#Preview("JournalsView") {
>>>>>>> dd0b2560b390dec1643ba67c1b666cbbb451f233:Lumora/Views/JournalsPage/Model/JournalsModel.swift
    JournalsView()
}

