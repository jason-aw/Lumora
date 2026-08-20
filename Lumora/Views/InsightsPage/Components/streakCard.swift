//
//  streakCard.swift
//  Lumora
//
//  Created by Kenneth Gabriel Libarnes on 13/11/2025.
//

import Foundation
import SwiftUI

struct streakCard:  View {
    private let cardBackground = Color(.systemGray5).opacity(0.25)
    private let cardStroke = Color.white.opacity(0.06)
    private let cardShadow = Color.black.opacity(0.35)
    
    @Bindable var model: InsightsViewModel
    
    var body: some View {
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
}
