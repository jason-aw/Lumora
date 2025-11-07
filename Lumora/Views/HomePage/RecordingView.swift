//
//  RecordingView.swift
//  Lumora
//
//  Created by Jason Andersen Winfrey on 7/11/2025.
//

import SwiftUI

struct RecordingView: View {
    var body: some View {
        NavigationStack {
            Text("This is a journal view")
            
            NavigationLink("Go to next page") {
                
                Text("New page")
                
            }
        }
    }
}

#Preview {
    RecordingView()
}
