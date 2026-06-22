//
//  MessageBubble.swift
//  weatherApp
//
//  Created by Narmin Baghirova on 18.06.26.
//

import SwiftUI

struct MessageBubble: View {
    let message: Message
    let isMe: Bool
    let userMail: String
    
    var body: some View {
        HStack {
            if isMe { Spacer() }
            VStack(alignment: isMe ? .trailing : .leading, spacing: 2) {
//                Text("\(userMail)")
//                    .font(.system(size: 12))
                Text(message.text)
                    .padding(8)
                    .background(isMe ? Color.blue : Color.green)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            if !isMe { Spacer() }
        }
        .padding(.horizontal, 8)
    }
}
