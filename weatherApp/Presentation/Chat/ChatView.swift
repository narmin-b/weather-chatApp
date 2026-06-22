//
//  ChatView.swift
//  weatherApp
//
//  Created by Narmin Baghirova on 18.06.26.
//

import SwiftUI

struct ChatView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var chatViewModel = ChatViewModel()
    @State private var messageText = ""
    @State private var isAlertShown: Bool = false
    @State private var alertMessage: String = ""
    @State private var isUserSelected: Bool = false

    let onSignOut: () -> Void
    
    var body: some View {
        if isUserSelected {
            VStack {
                HStack {
                    Spacer()
                    Button("Logout") {
                        authViewModel.signOut { error in
                            if let error = error {
                                isAlertShown = true
                                alertMessage = "Sign out failed! \(error.localizedDescription)"
                            } else {
                                onSignOut()
                            }
                        }
                    }
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
            
            .alert("Error", isPresented: $isAlertShown, actions: {
            }, message: {
                Text(alertMessage)
            })
            .padding()
            .onChange(of: UserDefaults.standard.string(forKey: "userId")) { uid in
                if uid != nil {
                    chatViewModel.startListening()
                }
            }
        } else {
            usersView
                .task {
                    await chatViewModel.fetchAllUsers()
                }
        }
    }
    
    var usersView: some View {
        VStack {
            ForEach(chatViewModel.users, id: \.self) { user in
                Text("\(user.email)")
                    .onTapGesture {
                        isUserSelected = true
                        chatViewModel.selectedUserID = user.uid
                        chatViewModel.startListening()
                    }
            }
        }
    }
}
