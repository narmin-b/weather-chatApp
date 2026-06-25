//
//  AuthViewModel.swift
//  weatherApp
//
//  Created by Narmin Baghirova on 18.06.26.
//

import Foundation
import FirebaseAuth
import Combine
import SwiftUI

class AuthViewModel: ObservableObject {
    private let authService: AuthService
    
    init(authService: AuthService = AuthService()) {
        self.authService = authService
    }
    
    func createAcc(email: String, password: String, completion: @escaping (Error?) -> Void) {
        authService.regularCreateAccount(email: email, password: password) { error in
            if let error = error {
                print("Sign in failed:", error.localizedDescription)
                completion(error)
            } else {
                UserDefaults.standard.set(Auth.auth().currentUser?.uid, forKey: "userId")
                completion(nil)
            }
        }
    }
    
    func login(email: String, password: String, completion: @escaping (Error?) -> Void) {
        authService.regularSignIn(email: email, password: password) { error in
            if let error = error {
                print("Log in failed:", error.localizedDescription)
                completion(error)
            } else {
                UserDefaults.standard.set(Auth.auth().currentUser?.uid, forKey: "userId")
                UserDefaults.standard.set(Auth.auth().currentUser?.email, forKey: "userEmail")
                completion(nil)
            }
        }
    }
    
    func signOut(completion: @escaping (Error?) -> Void) {
        authService.regularSignOut { error in
            if let error = error {
                print("Sign out failed:", error.localizedDescription)
                completion(error)
            } else {
                UserDefaults.standard.set(nil, forKey: "userId")
                UserDefaults.standard.set(nil, forKey: "userEmail")
                completion(nil)
            }
        }
    }
}
