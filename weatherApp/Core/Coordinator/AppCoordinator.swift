//
//  AppCoordinator.swift
//  weatherApp
//
//  Created by Narmin Baghirova on 25.06.26.
//

import SwiftUI
import Combine
import AppServices

@MainActor
final class AppCoordinator: ObservableObject {
    @Published var path = NavigationPath()
    
    func push(_ page: AppPage) {
        path.append(page)
    }
    
    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }
    
    func popToRoot() {
        path = NavigationPath()
    }
    
    @ViewBuilder
    func build(_ page: AppPage) -> some View {
        switch page {
        case .main:
            MainTabView()
        case .chat(let user):
            ChatView(
                recieverUser: RecieverUser(
                    userID: user.userID,
                    userEmail: user.userEmail
                )
            )
        case .usersList:
            UsersListView()
        }
    }
}
