//
//  NavigationBarView.swift
//  Lumora
//
//  Created by Jason Andersen Winfrey on 7/11/2025.
//

import SwiftUI

struct RootView: View {
    var body: some View {
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
        .preferredColorScheme(.dark)
       
    }
}

#Preview {
    RootView()
}
