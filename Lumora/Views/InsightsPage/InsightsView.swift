//
//  InsightsView.swift
//  Lumora
//
//  Created by Jason Andersen Winfrey on 7/11/2025.
//

import SwiftUI

struct InsightsView: View {
    @State private var model = InsightsViewModel()
    @State private var summaryModel = SummaryModel()
    @Environment(JournalsViewModel.self) var journalModel
    
    @State private var dragAmount = CGSize.zero
    
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
                    .padding(.top, 15)
                    .padding(.horizontal, 24)
                
                // Top grid with two cards
                LazyVGrid(columns: gridColumns, spacing: 16) {
                    streakCard(model: model)
                    moodTrendsCard(model: model)
                }
                .padding(.horizontal, 16)
                
                // AI Insights large card
                aiInsightsCard(model: model)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 32)
            }
            .offset(dragAmount)
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        dragAmount = CGSize(width: 0, height: gesture.translation.height)
                    }
                    .onEnded { gesture in
                        if gesture.translation.height > 100 {
                            updateInsights()
                        }
                        withAnimation{
                            dragAmount = .zero
                        }
                    }
            )
        }
        .background(Color("backgroundColor").ignoresSafeArea())
        
    }
        
    func updateInsights(){
        Task{
            model.aiBullets = []
            if summaryModel.chat == nil {
                summaryModel.startChat()
            }
            
            var pastTranscript = ""
            journalModel.entries.forEach { entry in
                pastTranscript += entry.fullText
            }
            
            let moodTrend = await summaryModel.sendChat(userInput: "Use instruction 2: " + pastTranscript)
            model.moodTrendSummary = moodTrend
            
            let bulletPoints = await summaryModel.sendChat(userInput: "Use instruction 3: " + pastTranscript)
            bulletPoints.split(separator: "*").forEach { point in
                model.aiBullets.append(String(point))
            }
        }
    }
}
    

    
    

