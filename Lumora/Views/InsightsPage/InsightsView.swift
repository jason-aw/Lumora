//
//  InsightsView.swift
//  Lumora
//
//  Created by Jason Andersen Winfrey on 7/11/2025.
//

import SwiftUI

// MARK: - ViewModel (stubbed data)
@Observable
final class InsightsViewModel {
    var streakNights: Int = 10
    var moodTrendSummary: String = "Your overall mood has been calmer compared to this week."
    var aiIntro: String = "Here’s some insights about your sleep this week"
    var aiBullets: [String] = [
        "Your sleep was shortest on nights when you expressed frustration.",
        "You’ve talked about work stress 3 times last week and it has led to less sleep than usual.",
        "Your sleep was shortest on nights when you expressed frustration."
    ]
}

struct InsightsView: View {
    @State private var model = InsightsViewModel()

    // Match JournalsView card styling for consistency
    private let cardBackground = Color(.systemGray5).opacity(0.25)
    private let cardStroke = Color.white.opacity(0.06)
    private let cardShadow = Color.black.opacity(0.35)

    private let gridColumns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Title
                Text("Sleep Insights")
                    .font(.system(size: 44, weight: .bold, design: .default))
                    .foregroundColor(.white)
                    .padding(.top, 8)
                    .padding(.horizontal, 24)

                // Top grid with two cards
                LazyVGrid(columns: gridColumns, spacing: 16) {
                    streakCard
                    moodTrendsCard
                }
                .padding(.horizontal, 16)

                // AI Insights large card
                aiInsightsCard
                    .padding(.horizontal, 16)
                    .padding(.bottom, 32)
            }
        }
        .background(Color("backgroundColor").ignoresSafeArea())
    }

    // MARK: - Cards

    private var streakCard: some View {
        RoundedRectangle(cornerRadius: 28, style: .continuous)
            .fill(cardBackground)
            .overlay(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .stroke(cardStroke, lineWidth: 1)
            )
            .shadow(color: cardShadow, radius: 12, x: 0, y: 8)
            .overlay(
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 10) {
                        Image(systemName: "flame.fill")
                            .foregroundColor(.white)
                            .font(.system(size: 20, weight: .semibold))
                        Text("Streak")
                            .foregroundColor(.white)
                            .font(.system(size: 20, weight: .semibold))
                        Spacer()
                    }

                    Text("You’ve journaled for")
                        .foregroundColor(.white.opacity(0.75))
                        .font(.system(size: 15))

                    HStack(alignment: .firstTextBaseline, spacing: 6) {
                        Text("\(model.streakNights)")
                            .foregroundColor(.white)
                            .font(.system(size: 48, weight: .bold, design: .default))
                        Text("nights")
                            .foregroundColor(.white.opacity(0.75))
                            .font(.system(size: 18, weight: .semibold))
                    }

                    Spacer(minLength: 0)
                }
                .padding(20)
            )
            .frame(height: 170)
    }

    private var moodTrendsCard: some View {
        RoundedRectangle(cornerRadius: 28, style: .continuous)
            .fill(cardBackground)
            .overlay(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .stroke(cardStroke, lineWidth: 1)
            )
            .shadow(color: cardShadow, radius: 12, x: 0, y: 8)
            .overlay(
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 10) {
                        Image(systemName: "face.smiling")
                            .foregroundColor(.white)
                            .font(.system(size: 20, weight: .semibold))
                        Text("Mood Trends")
                            .foregroundColor(.white)
                            .font(.system(size: 20, weight: .semibold))
                        Spacer()
                    }

                    Text(model.moodTrendSummary)
                        .foregroundColor(.white.opacity(0.75))
                        .font(.system(size: 16))
                        .fixedSize(horizontal: false, vertical: true)

                    Spacer(minLength: 0)
                }
                .padding(20)
            )
            .frame(height: 170)
    }

    private var aiInsightsCard: some View {
        RoundedRectangle(cornerRadius: 32, style: .continuous)
            .fill(cardBackground)
            .overlay(
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .stroke(cardStroke, lineWidth: 1)
            )
            .shadow(color: cardShadow, radius: 16, x: 0, y: 10)
            .overlay(
                VStack(alignment: .leading, spacing: 16) {
                    // Header
                    HStack(spacing: 10) {
                        Image(systemName: "lightbulb")
                            .foregroundColor(.white)
                            .font(.system(size: 22, weight: .semibold))
                        Text("AI Insights")
                            .foregroundColor(.white)
                            .font(.system(size: 22, weight: .semibold))
                        Spacer()
                    }

                    // Intro
                    Text(model.aiIntro)
                        .foregroundColor(.white.opacity(0.85))
                        .font(.system(size: 18, weight: .semibold))

                    // Bulleted list
                    VStack(alignment: .leading, spacing: 14) {
                        ForEach(model.aiBullets.indices, id: \.self) { idx in
                            HStack(alignment: .top, spacing: 10) {
                                Text("•")
                                    .font(.system(size: 20, weight: .regular))
                                    .foregroundColor(.white.opacity(0.9))
                                    .padding(.top, 1)

                                Text(model.aiBullets[idx])
                                    .font(.system(size: 16))
                                    .foregroundColor(.white.opacity(0.85))
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }

                    Spacer(minLength: 0)
                }
                .padding(24)
            )
            .frame(minHeight: 340)
    }
}

#Preview {
    InsightsView()
}
