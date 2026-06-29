//
//  ChatView.swift
//  weatherApp
//
//  Created by Narmin Baghirova on 18.06.26.
//

import SwiftUI
import AppServices

struct ChatView: View {
    @StateObject private var chatViewModel: ChatViewModel
    @EnvironmentObject private var coordinator: AppCoordinator

    @State private var messageText = ""
    @State private var isAlertShown = false
    @State private var alertMessage = ""

    init(recieverUser: RecieverUser) {
        _chatViewModel = StateObject(
            wrappedValue: ChatViewModel(recieverUser: recieverUser)
        )
    }

    var body: some View {
        VStack {
            chatView

            messageTextfield
        }
        .padding()
        .alert("Error", isPresented: $isAlertShown) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
        .onAppear {
            chatViewModel.startListening { error in
                if let error {
                    isAlertShown = true
                    alertMessage = error
                }
            }
        }
        .navigationTitle("\(chatViewModel.recieverUser.userEmail)")
    }
    
    //MARK: Components
    var chatView: some View {
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
    }
    
    var messageTextfield: some View {
        HStack {
            TextField("Message...", text: $messageText)
                .textFieldStyle(.roundedBorder)
            
            sendButton
        }
    }
    
    var sendButton: some View {
        Button("Send") {
            let text = messageText.trimmingCharacters(in: .whitespacesAndNewlines)

            guard !text.isEmpty else { return }

            chatViewModel.sendMessage(text: text) { error in
                if let error {
                    isAlertShown = true
                    alertMessage = error
                }
            }

            messageText = ""
        }
        .disabled(
            UserDefaults.standard.string(forKey: "userId") == nil ||
            messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        )
    }
}

