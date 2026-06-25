//
//  AuthService.swift
//  weatherApp
//
//  Created by Narmin Baghirova on 19.06.26.
//

import Foundation
import FirebaseCore
import FirebaseAuth
import Combine
import FirebaseFirestore

class AuthService: ObservableObject {
    private let db = Firestore.firestore()
    private let firebaseAuth = Auth.auth()

    @Published var signedIn: Bool = false
    @Published var users: [MessagerUser] = []
    
    init() {
    }
    
    func regularCreateAccount(
        email: String,
        password: String,
        completion: @escaping (Error?) -> Void
    ) {
        firebaseAuth.createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                completion(error)
                return
            }

            Task {
                do {
                    let uid = authResult?.user.uid ?? ""
                    let email = authResult?.user.email ?? email

                    try await self.createUserInDatabase(uid: uid, email: email)

                    print("Successfully created password account")
                    completion(nil)
                } catch {
                    completion(error)
                }
            }
        }
    }
        
        func regularSignIn(email:String, password:String, completion: @escaping (Error?) -> Void) {
            firebaseAuth.signIn(withEmail: email, password: password) { authResult, error in
            if let e = error {
                completion(e)
            } else {
                completion(nil)
            }
        }
    }
    
    func regularSignOut(completion: @escaping (Error?) -> Void) {
        do {
            try firebaseAuth.signOut()
            completion(nil)
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
            completion(signOutError)
        }
    }
    
    func createUserInDatabase(uid: String, email: String) async throws {
        let userRef = db.collection("users").document(uid)
        let snapshot = try await userRef.getDocument()
        
        if snapshot.exists {
            return
        }
        
        try await userRef.setData([
            "uid": uid,
            "email": email
        ])
    }
    
    func fetchUserLists(completion: @escaping (String?) -> Void) async {
        do {
            let snapshot = try await db.collection("users").getDocuments()
            let currentUID = firebaseAuth.currentUser?.uid

            let fetchedUsers: [MessagerUser] = snapshot.documents.compactMap { document in
                guard document.documentID != currentUID else {
                    return nil
                }

                return try? document.data(as: MessagerUser.self) 
            }

            await MainActor.run {
                self.users = fetchedUsers
                print("users: \(self.users)")
            }
        } catch {
            completion(error.localizedDescription)
        }
    }
}
