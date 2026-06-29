//
//  UsersListViewModel.swift
//  weatherApp
//
//  Created by Narmin Baghirova on 25.06.26.
//

import Foundation
import Combine
import AppServices

@MainActor
final class UsersListViewModel: ObservableObject {
    @Published private(set) var users: [MessagerUser] = []
    @Published private(set) var errorMessage: String?

    private let authService: AuthService

    init(authService: AuthService? = nil) {
        self.authService = authService ?? AuthService()
    }

    func fetchAllUsers(
        completion: @escaping (String?) -> Void
    ) async {
        do {
            users = try await authService.fetchUsers()
            errorMessage = nil
            completion(nil)
        } catch {
            let message = error.localizedDescription
            errorMessage = message
            completion(message)
        }
    }
}
