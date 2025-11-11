//
//  RecordingView.swift
//  Lumora
//
//  Created by Jason Andersen Winfrey on 7/11/2025.
//

import SwiftUI
import AVFAudio

struct RecordingView: View {
    @State private var transcriptMic = MicTranscript()
    @State private var showTranscript: Bool = true
    @State private var startingOffset: CGFloat = UIScreen.main.bounds.height * 0.85
    @State private var currentOffset:CGFloat = 0
    @State private var endOffset:CGFloat = 0
    
    var body: some View {

        ZStack{
            BlobView(transcriptMic: transcriptMic)
            
            VStack{
                Button ("toggle"){
                    if transcriptMic.audioEngine.isRunning{
                        transcriptMic.stopListening()
                    } else {
                        transcriptMic.startListening()
                    }
                }
                .background(.red)
            }
            
            VStack{
                TranscriptPullUp(transcriptMic: transcriptMic)
                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                    .clipShape(RoundedRectangle(cornerRadius: 32))
                    .offset(y:startingOffset)
                    .offset(y:currentOffset)
                    .offset(y:endOffset)
                    .gesture(
                        DragGesture()
                            .onChanged{ value in
                                withAnimation(.spring()){
                                    currentOffset = value.translation.height
                                }
                            }
                        
                            .onEnded{ value in
                                withAnimation(.spring()){
                                    if currentOffset < -150{
                                        endOffset = -startingOffset * 0.8
                                    }else if endOffset != 0 && currentOffset > 150 {
                                        endOffset = -30
                                    }
                                    currentOffset = 0
                                }
                            }
                    )
            }
            
        }

        NavigationView { 
                   Text("Content with hidden navigation bar")
                       .toolbar(.hidden, for: .navigationBar)
               }
        
    }
}

#Preview {

}
