//
//  UsersListView.swift
//  weatherApp
//
//  Created by Narmin Baghirova on 22.06.26.
//

import SwiftUI

struct UsersListView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject private var coordinator: AppCoordinator
    @StateObject private var usersViewModel = UsersListViewModel()

    @State private var isAlertShown: Bool = false
    @State private var isUserSelected: Bool = false
    @State private var alertMessage: String = ""
        
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Spacer()
                Button("Logout") {
                    authViewModel.signOut { error in
                        if let error = error {
                            isAlertShown = true
                            alertMessage = "Sign out failed! \(error.localizedDescription)"
                        } else {
                            coordinator.pop()
                        }
                    }
                }
            }
            .padding()
            
            Text("Users list:")
                .font(.system(.largeTitle))
                .padding()
            
            List(usersViewModel.users) { user in
                        Button {
                            coordinator.push(.chat(user: ReceiverUser(userID: user.id, userEmail: user.email)))
                        } label: {
                            Text(user.email)
                        }
                    }
            
            Spacer()
        }
        .alert("Error", isPresented: $isAlertShown, actions: {
        }, message: {
            Text(alertMessage)
        })
        .task {
            await usersViewModel.fetchAllUsers() { error in
                if let error = error {
                    isAlertShown = true
                    alertMessage = error
                }
            }
        }
        .navigationBarBackButtonHidden()
    }
}
