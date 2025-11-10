//
//  HomeView.swift
//  Lumora
//
//  Created by Jason Andersen Winfrey on 7/11/2025.
//

import SwiftUI

struct HomeView: View {
    
    var body: some View {
        
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
