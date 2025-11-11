//
//  TranscriptPullUp.swift
//  Lumora
//
//  Created by Kenneth Gabriel Libarnes on 10/11/2025.
//

import SwiftUI

struct TranscriptPullUp: View {
    @Bindable var transcriptMic: MicTranscript
    
    var body: some View {
        VStack{
            
            //GRABBER
            Rectangle()
                .frame(width: 60, height: 6)
                .clipShape(RoundedRectangle(cornerRadius: 32))
                .padding(.top, 20)
                .foregroundColor(Color("secondcolor"))
            Spacer()
            //
            
            Text(transcriptMic.currSpeech)
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("backgroundColor"))
    }
    
}

