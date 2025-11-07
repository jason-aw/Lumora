//
//  HomeView.swift
//  Lumora
//
//  Created by Jason Andersen Winfrey on 7/11/2025.
//

import SwiftUI

struct HomeView: View {
    
    var body: some View {
        VStack {
            BlobView()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("backgroundColor"))
    }
}

#Preview {
    HomeView()
}
