//
//  ChatService.swift
//  weatherApp
//
//  Created by Narmin Baghirova on 25.06.26.
//

import Foundation
import FirebaseCore
import FirebaseAuth
import Combine
import FirebaseFirestore

final class ChatService {
    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?

    func sendMessage(
        text: String,
        senderID: String,
        senderMail: String,
        recieverUser: ReceiverUser,
        completion: @escaping (String?) -> Void
    ) {
        guard !senderID.isEmpty else {
            completion("Current user ID not found.")
            return
        }

        let chatID = [senderID, recieverUser.userID]
            .sorted()
            .joined(separator: "_")

        let chatRef = db.collection("chats").document(chatID)

        chatRef.setData([
            "chatID": chatID,
            "participants": [senderID, recieverUser.userID],
            "lastMessage": text,
            "timestamp": Timestamp()
        ], merge: true) { error in
            if let error {
                completion(error.localizedDescription)
                return
            }

            chatRef.collection("messages").addDocument(data: [
                "text": text,
                "senderID": senderID,
                "receiverID": recieverUser.userID,
                "senderMail": senderMail,
                "timestamp": Timestamp()
            ]) { error in
                if let error {
                    completion(error.localizedDescription)
                } else {
                    completion(nil)
                }
            }
        }
    }

    func startListening(
        recieverUser: ReceiverUser,
        onMessagesChanged: @escaping ([Message]) -> Void,
        completion: @escaping (String?) -> Void
    ) {
        guard let currentUserID = UserDefaults.standard.string(forKey: "userId") else {
            completion("Current user ID not found.")
            return
        }

        guard !recieverUser.userID.isEmpty else {
            completion("Receiver user ID is empty.")
            return
        }

        let chatID = [currentUserID, recieverUser.userID]
            .sorted()
            .joined(separator: "_")

        print("chatID:", chatID)

        listener?.remove()

        listener = db.collection("chats")
            .document(chatID)
            .collection("messages")
            .order(by: "timestamp", descending: false)
            .addSnapshotListener { snapshot, error in
                if let error {
                    completion(error.localizedDescription)
                    return
                }

                guard let documents = snapshot?.documents else {
                    onMessagesChanged([])
                    return
                }

                let messages = documents.map { doc in
                    let data = doc.data()

                    return Message(
                        id: doc.documentID,
                        text: data["text"] as? String ?? "",
                        senderID: data["senderID"] as? String ?? "",
                        senderMail: data["senderMail"] as? String ?? "",
                        timestamp: (data["timestamp"] as? Timestamp)?.dateValue() ?? Date()
                    )
                }

                onMessagesChanged(messages)
                completion(nil)
            }
    }

    func stopListening() {
        listener?.remove()
        listener = nil
    }
}
