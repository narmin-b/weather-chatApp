//
//  ChatView.swift
//  weatherApp
//
//  Created by Narmin Baghirova on 18.06.26.
//

import SwiftUI

struct ChatView: View {
    @StateObject private var chatViewModel: ChatViewModel
    @EnvironmentObject private var coordinator: AppCoordinator

    @State private var messageText = ""
    @State private var isAlertShown = false
    @State private var alertMessage = ""

    init(recieverUser: ReceiverUser) {
        _chatViewModel = StateObject(
            wrappedValue: ChatViewModel(recieverUser: recieverUser)
        )
    }

    var body: some View {
        VStack {
            HStack {
                Text(chatViewModel.recieverUser.userEmail)
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
    }
}
