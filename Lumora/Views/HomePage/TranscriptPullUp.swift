//
//  TranscriptPullUp.swift
//  Lumora
//
//  Created by Kenneth Gabriel Libarnes on 10/11/2025.
//

import SwiftUI
import Foundation

// MARK: - Transcript View

struct TranscriptPullUp: View {
    @Binding var chatLogs: [ChatLog]
    @Bindable var transcriptMic: MicTranscript
    @Environment(JournalsViewModel.self) var model
    
    var body: some View {
        VStack(spacing: 0) {
            
            // THE GRABBER
            RoundedRectangle(cornerRadius: 3)
                .fill(Color("secondcolor"))
                .frame(width: 50, height: 6)
                .padding(.top, 20)

            // TRANSCRIPT TITLE
            Text("Transcript")
                .font(.system(size: 25, weight: .bold, design: .default))
                .foregroundColor(Color("firstcolor"))
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.horizontal, 24)
                .padding(.top, 17)
            
            //Button ("add journal entry") {
                //model.addEntry(chatLogs: chatLogs)
            //}
            //.buttonStyle(PlainButtonStyle())
            
            // TRANSCRIPT CHAT
            ScrollViewReader { proxy in
                ScrollView {
                    //Every new message, the array grows
                    LazyVStack(alignment: .leading, spacing: 20) {
                        ForEach(chatLogs) { turn in
                            messageRow(for: turn)
                        }
            
                        if transcriptMic.currSpeech != "..." {
                            messageRow(for: .init(text: transcriptMic.currSpeech, isUser: true))
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                    .onChange(of: chatLogs.count) { _, _ in
                        if let last = chatLogs.last {
                            proxy.scrollTo(last.id, anchor: .bottom)
                        }
                    }
                }
            }
            Spacer(minLength: 0)
            .background(.red)
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("backgroundColor"))
    }
    
    // MARK: - Transcript Text UI
    // Returning one row for every transcript message
    
    @ViewBuilder
    private func messageRow(for turn: ChatLog) -> some View {
        // IF MESSAGE IS FROM THE USER
        if turn.isUser {
            HStack {
                Spacer(minLength: 40)
                // USER TRANSCRIPT UI TEXT
                Text(turn.text)
                    .font(.system(size: 17, weight: .semibold, design: .default))
                    .foregroundColor(Color("text2"))
                    .multilineTextAlignment(.trailing)
                    .frame(maxWidth: 270, alignment: .trailing)
                    .padding(.vertical, 4)
            }
            .id(turn.id)
        // AI CONVO
        } else {
            // AI TRANSCRIPT BAR
            HStack(alignment: .top, spacing: 12) {
                Color("text1")
                    .frame(width: 4)
                    .cornerRadius(2)
                    .padding(.vertical, 4)
                
                // AI TRANSCRIPT UI TEXT
                Text(turn.text)
                    .font(.system(size: 17, weight: .semibold, design: .default))
                    .foregroundColor(Color("text1"))
                    .frame(maxWidth: 270, alignment: .leading)
                    .padding(.vertical, 4)
            }
            .id(turn.id)
        }
    }
}

