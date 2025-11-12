// Micmute and cancel Buttons
// By Vrudangi

import SwiftUI

struct GlassButton: View {
    let systemImage: String
    let action: () -> Void

    init(systemImage: String, action: @escaping () -> Void) {
        self.systemImage = systemImage
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .frame(width: 50, height: 50)
                .foregroundColor(.white)
        }
        .glassEffect() // circular liquid glass
    }
}

#Preview {
    HStack(spacing: 24) {
        GlassButton(systemImage: "mic.fill") { }
        GlassButton(systemImage: "xmark") { }
    }
    .padding(32)
    .background(Color.black)
    .preferredColorScheme(.dark)
}
