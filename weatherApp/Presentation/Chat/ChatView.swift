//
//  ChatView.swift
//  weatherApp
//
//  Created by Narmin Baghirova on 18.06.26.
//

import SwiftUI

struct ChatView: View {
    @EnvironmentObject var chatViewModel: ChatViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var isUserSelected: Bool = false
    @State private var messageText = ""

    var chatEmail: String = ""
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "chevron.left")
                    .font(.system(size: 24))
                    .onTapGesture {
                        print("dismissed")
                        dismiss()
                    }
                
                Spacer()
                
                Text("\(chatViewModel.recieverUser.userEmail)")
                    .font(.system(size: 24))
                
                Spacer()
            }
            
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 8) {
                    ForEach(chatViewModel.messages) { message in
                        MessageBubble(
                            message: message,
                            isMe: message.senderID == UserDefaults.standard.string(forKey: "userId"),
                            userMail: message.senderMail
                        )
                    }
                }
            }
            
            HStack {
                TextField("Message...", text: $messageText)
                    .textFieldStyle(.roundedBorder)
                
                Button("Send") {
                    chatViewModel.sendMessage(
                        text: messageText,
                        senderID: UserDefaults.standard.string(forKey: "userId") ?? "",
                        senderMail: UserDefaults.standard.string(forKey: "userEmail") ?? ""
                    )
                    messageText = ""
                }
                .disabled(UserDefaults.standard.string(forKey: "userId") == nil || messageText.isEmpty)
            }
        }
        .onAppear {
            chatViewModel.startListening()
        }
        .padding()
    }
}
