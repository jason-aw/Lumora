//
//  NavigationBarView.swift
//  Lumora
//
//  Created by Jason Andersen Winfrey on 7/11/2025.
//

import SwiftUI

struct RootView: View {
    var body: some View {
        ZStack {
            // Global background color
            Color("backgroundColor")
                .ignoresSafeArea()
            
            // Prismatic glow behind tabs
            PrismaticBubbleView(
                size: 320,
                blur: 22,
                animationSpeed: 1.2,
                breatheAmount: 0.035
            )
            .allowsHitTesting(false) // keep it non-interactive
            .accessibilityHidden(true)
            
            TabView {
                Tab("Home", systemImage: "house") {
                    HomeView()
                }
                Tab("Insights", systemImage: "chart.bar.xaxis.ascending") {
                    InsightsView()
                }
                Tab("Journals", systemImage: "book.pages") {
                    JournalsView()
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    RootView()
}
