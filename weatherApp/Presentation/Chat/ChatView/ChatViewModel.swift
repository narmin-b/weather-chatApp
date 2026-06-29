//
//  ChatViewModel.swift
//  weatherApp
//
//  Created by Narmin Baghirova on 18.06.26.
//

import Foundation
import Combine
import AppServices

@MainActor
final class ChatViewModel: ObservableObject {
    @Published private(set) var messages: [Message] = []
    @Published private(set) var errorMessage: String?
    @Published var recieverUser: RecieverUser

    private let chatService: ChatService

    init(
        recieverUser: RecieverUser,
        chatService: ChatService? = nil
    ) {
        self.recieverUser = recieverUser
        self.chatService = chatService ?? ChatService()
    }

    func startListening(
        completion: @escaping @MainActor @Sendable (String?) -> Void
    ) {
        chatService.startListening(
            recieverUser: recieverUser,
            onMessagesChanged: { [weak self] messages in
                Task { @MainActor in
                    self?.messages = messages
                }
            },
            completion: { [weak self] error in
                Task { @MainActor in
                    self?.errorMessage = error
                    completion(error)
                }
            }
        )
    }

    func sendMessage(
        text: String,
        completion: @escaping @MainActor @Sendable (String?) -> Void
    ) {
        let senderID = UserDefaults.standard.string(
            forKey: "userId"
        ) ?? ""

        let senderEmail = UserDefaults.standard.string(
            forKey: "userEmail"
        ) ?? ""

        chatService.sendMessage(
            text: text,
            senderID: senderID,
            senderMail: senderEmail,
            recieverUser: recieverUser
        ) { [weak self] error in
            Task { @MainActor in
                self?.errorMessage = error
                completion(error)
            }
        }
    }

    func stopListening() {
        chatService.stopListening()
    }
}
