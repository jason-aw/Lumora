//
//  aiInsightsCard.swift
//  Lumora
//
//  Created by Kenneth Gabriel Libarnes on 13/11/2025.
//

import SwiftUI
import Foundation


struct aiInsightsCard: View {
    private let cardBackground = Color(.systemGray5).opacity(0.25)
    private let cardStroke = Color.white.opacity(0.06)
    private let cardShadow = Color.black.opacity(0.35)
    
    @Bindable var model: InsightsViewModel
    
    var body: some View{
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
