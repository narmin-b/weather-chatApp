//
//  AuthService.swift
//  weatherApp
//
//  Created by Narmin Baghirova on 19.06.26.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

@MainActor
public final class AuthService {
    private let db: Firestore
    private let firebaseAuth: Auth
    private var listener: ListenerRegistration?
    
    public init() {
        self.db = Firestore.firestore()
        self.firebaseAuth = Auth.auth()
    }
    
    public var currentUserID: String? {
        firebaseAuth.currentUser?.uid
    }

    public var currentUserEmail: String? {
        firebaseAuth.currentUser?.email
    }

    public func createAccount(
        email: String,
        password: String
    ) async throws {
        let result = try await firebaseAuth.createUser(
            withEmail: email,
            password: password
        )

        guard let email = result.user.email else {
            throw ServiceError.missingAuthenticatedUser
        }

        try await createUserInDatabase(
            uid: result.user.uid,
            email: email
        )
    }

    public func signIn(
        email: String,
        password: String
    ) async throws {
        _ = try await firebaseAuth.signIn(
            withEmail: email,
            password: password
        )
    }

    public func signOut() throws {
        try firebaseAuth.signOut()
    }

    public func fetchUsers() async throws -> [MessagerUser] {
        let snapshot = try await db
            .collection("users")
            .getDocuments()

        let currentUserID = firebaseAuth.currentUser?.uid

        return snapshot.documents.compactMap { document in
            guard document.documentID != currentUserID else {
                return nil
            }

            return try? document.data(as: MessagerUser.self)
        }
    }

    private func createUserInDatabase(
        uid: String,
        email: String
    ) async throws {
        let reference = db
            .collection("users")
            .document(uid)

        let snapshot = try await reference.getDocument()

        guard !snapshot.exists else {
            return
        }

        try await reference.setData([
            "uid": uid,
            "email": email
        ])
    }
}
