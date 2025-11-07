//
//  InsightsView.swift
//  Lumora
//
//  Created by Jason Andersen Winfrey on 7/11/2025.
//

import SwiftUI

struct InsightsView: View {
    var body: some View {
        VStack {
            Text("This is the insights page")
                .font(Font.largeTitle)
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("backgroundColor"))
        
    }
}

#Preview {
    InsightsView()
}
