//
//  JournalsDataModel.swift
//  Lumora
//
//  Created by Emily Heng on 10/11/2025.
//

import SwiftUI

// MARK: - UI OF TRANSCRIPT MESSAGE ROW
struct TranscriptMessageRow: View {
    let chatLog: ChatLog
    
    var body: some View {
        Group {
            if chatLog.isUser {
                // USER MESSAGE (Right)
                HStack {
                    Spacer(minLength: 40)
                    Text(chatLog.text)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(Color("text2"))
                        .multilineTextAlignment(.trailing)
                        .frame(maxWidth: 270, alignment: .trailing)
                        .padding(.vertical, 4)
                }
            } else {
                // AI MESSAGE (left)
                HStack(alignment: .top, spacing: 12) {
                    Color("text1")
                        .frame(width: 4)
                        .cornerRadius(2)
                        .padding(.vertical, 4)
                    Text(chatLog.text)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(Color("text1"))
                        .frame(maxWidth: 270, alignment: .leading)
                        .padding(.vertical, 4)
                }
            }
        }
        .id(chatLog.id)
    }
}

