//
//  AuthViewModel.swift
//  weatherApp
//
//  Created by Narmin Baghirova on 18.06.26.
//

import Foundation
import Combine
import AppServices

@MainActor
final class AuthViewModel: ObservableObject {
    private let authService: AuthService
    
    init(authService: AuthService? = nil) {
        self.authService = authService ?? AuthService()
    }
    
    func createAcc(
        email: String,
        password: String
    ) async throws {
        do {
            try await authService.createAccount(
                email: email,
                password: password
            )

            saveCurrentUser()
        } catch {
            print(
                "Account creation failed:",
                error.localizedDescription
            )
            throw error
        }
    }

    func login(
        email: String,
        password: String
    ) async throws {
        do {
            try await authService.signIn(
                email: email,
                password: password
            )

            saveCurrentUser()
        } catch {
            print(
                "Login failed:",
                error.localizedDescription
            )
            throw error
        }
    }

    func signOut() throws {
        try authService.signOut()

        UserDefaults.standard.removeObject(forKey: "userId")
        UserDefaults.standard.removeObject(forKey: "userEmail")
    }

    private func saveCurrentUser() {
        UserDefaults.standard.set(
            authService.currentUserID,
            forKey: "userId"
        )

        UserDefaults.standard.set(
            authService.currentUserEmail,
            forKey: "userEmail"
        )
    }
}
