//
//  ChatViewModel.swift
//  weatherApp
//
//  Created by Narmin Baghirova on 18.06.26.
//

import Foundation
import FirebaseFirestore
import Combine
import SwiftUI

class ChatViewModel: ObservableObject {
    @Published var messages: [Message] = []
    @Published var users: [MessagerUser] = []
    @Published var errorMessage: String?
    @Published var recieverUser: ReceiverUser
    
    private let authService: AuthService
    private let chatService: ChatService
    
    init(
        authService: AuthService = AuthService(),
        chatService: ChatService = ChatService(),
        recieverUser: ReceiverUser
    ) {
        self.recieverUser = recieverUser
        self.authService = authService
        self.chatService = chatService
    }
    
    func startListening(completion: @escaping (String?) -> Void) {
        chatService.startListening(
            recieverUser: recieverUser,
            onMessagesChanged: { [weak self] messages in
                Task { @MainActor in
                    self?.messages = messages
                }
            },
            completion: { [weak self] error in
                Task { @MainActor in
                    if let error {
                        self?.errorMessage = error
                        completion(error)
                    }
                }
            }
        )
    }
    
    func sendMessage(text: String, completion: @escaping (String?) -> Void) {
        chatService.sendMessage(
            text: text,
            senderID: UserDefaults.standard.string(forKey: "userId") ?? "",
            senderMail: UserDefaults.standard.string(forKey: "userEmail") ?? "",
            recieverUser: recieverUser
        ) { error in
            if let error = error {
                self.errorMessage = error
                return
            }
        }
    }
    
    func fetchAllUsers(completion: @escaping (String?) -> Void) async {
        await authService.fetchUserLists { error in
            if let error = error {
                self.errorMessage = error
                return
            }
        }
        users = authService.users
    }
}
