//
//  UsersListViewModel.swift
//  weatherApp
//
//  Created by Narmin Baghirova on 25.06.26.
//

import Foundation
import Combine

@MainActor
final class UsersListViewModel: ObservableObject {
    @Published var users: [MessagerUser] = []
    @Published var errorMessage: String?

    private let authService: AuthService

    init(authService: AuthService = AuthService()) {
        self.authService = authService
    }

    func fetchAllUsers(completion: @escaping (String?) -> Void) async {
        await authService.fetchUserLists { error in
            if let error {
                self.errorMessage = error
                completion(error)
                return
            }
        }

        self.users = authService.users
        completion(nil)
    }
}
