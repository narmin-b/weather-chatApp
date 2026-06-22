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
    var selectedUserID: String = ""
    
    private let authService: AuthService
    
    init(authService: AuthService = AuthService()) {
        self.authService = authService
    }
    
    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?
    
    func startListening() {
        guard let currentUserID = UserDefaults.standard.string(forKey: "userId") else {
            return
        }

        let chatID = [currentUserID, selectedUserID].sorted().joined(separator: "_")

        listener?.remove()

        listener = db.collection("chats")
            .document(chatID)
            .collection("messages")
            .order(by: "timestamp")
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Listen error: \(error.localizedDescription)")
                    return
                }

                self.messages = snapshot?.documents.map { doc in
                    let data = doc.data()

                    return Message(
                        id: doc.documentID,
                        text: data["text"] as? String ?? "",
                        senderID: data["senderID"] as? String ?? "",
                        senderMail: data["senderMail"] as? String ?? "",
                        timestamp: (data["timestamp"] as? Timestamp)?.dateValue() ?? Date()
                    )
                } ?? []
            }
    }
    
    func sendMessage(text: String, senderID: String, senderMail: String) {
        let chatID = [senderID, selectedUserID].sorted().joined(separator: "_")
        
        let chatRef = db.collection("chats").document(chatID)
        
        chatRef.setData([
            "chatID": chatID,
            "participants": [senderID, selectedUserID],
            "lastMessage": text,
            "timestamp": Timestamp()
        ], merge: true)
        
        chatRef.collection("messages").addDocument(data: [
            "text": text,
            "senderID": senderID,
            "receiverID": selectedUserID,
            "senderMail": senderMail,
            "timestamp": Timestamp()
        ])
    }
    
    func fetchAllUsers() async {
        await authService.fetchUserLists()
        users = authService.users
    }
}
