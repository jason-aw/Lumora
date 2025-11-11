//
//  HomeView.swift
//  Lumora
//
//  Created by Jason Andersen Winfrey on 7/11/2025.
//

import SwiftUI

struct HomeView: View {
    var body: some View {

        ZStack {
            Color("backgroundColor").ignoresSafeArea()
            PrismaticBubbleView(size: 260, blur: 16, animationSpeed: 1.2, breatheAmount: 0.035)
                .allowsHitTesting(false)
                .accessibilityHidden(true)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)

        
        NavigationStack {
            NavigationLink(destination: RecordingView()){
                BlobView(transcriptMic: MicTranscript())
            }
        }
    }
}

#Preview {
    HomeView()
}
