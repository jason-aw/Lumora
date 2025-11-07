//
//  JournalsView.swift
//  Lumora
//
//  Created by Jason Andersen Winfrey on 7/11/2025.
//

import SwiftUI

struct JournalsView: View {
    var body: some View {
        VStack {
            Text("This is the journals page")
                .font(Font.largeTitle)
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("backgroundColor"))
    }
}

#Preview {
    JournalsView()
}
