//
//  UsersListView.swift
//  weatherApp
//
//  Created by Narmin Baghirova on 22.06.26.
//

import SwiftUI
import AppServices

struct UsersListView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel
    @EnvironmentObject private var coordinator: AppCoordinator

    @StateObject private var usersViewModel = UsersListViewModel()

    @State private var isAlertShown = false
    @State private var alertMessage = ""

    var body: some View {
        VStack(alignment: .leading) {
            logoutButton
                .padding()
            
            usersListHeader
                .padding()

            usersList

            Spacer()
        }
        .alert(
            "Error",
            isPresented: $isAlertShown
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
        .task {
            await usersViewModel.fetchAllUsers { error in
                guard let error else { return }

                alertMessage = error
                isAlertShown = true
            }
        }
        .navigationBarBackButtonHidden()
    }

    private func signOut() {
        do {
            try authViewModel.signOut()
            coordinator.pop()
        } catch {
            alertMessage = "Sign out failed: \(error.localizedDescription)"
            isAlertShown = true
        }
    }
    
    //MARK: Components
    var logoutButton: some View {
        HStack {
            Spacer()

            Button("Logout") {
                signOut()
            }
        }
    }
    
    var usersListHeader: some View {
        Text("Users list:")
            .font(.system(.largeTitle))
    }
    
    var usersList: some View {
        List(usersViewModel.users, id: \.uid) { user in
            UserListRow(userEmail: user.email) {
                coordinator.push(
                    .chat(
                        user: RecieverUser(
                            userID: user.uid,
                            userEmail: user.email
                        )
                    )
                )
            }
        }
        .scrollContentBackground(.hidden)
    }
}

