//
//  UsersListView.swift
//  weatherApp
//
//  Created by Narmin Baghirova on 22.06.26.
//

import SwiftUI

struct UsersListView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var chatViewModel = ChatViewModel()
    @State private var isAlertShown: Bool = false
    @State private var isUserSelected: Bool = false
    @State private var alertMessage: String = ""
    
    let onSignOut: () -> Void
    
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
                            onSignOut()
                        }
                    }
                }
            }
            .padding()
            
            Text("Users list:")
                .font(.system(.largeTitle))
                .padding()
            
            List {
                ForEach(chatViewModel.users, id: \.self) { user in
                    Text("\(user.email)")
                        .onTapGesture {
                            isUserSelected = true
                            chatViewModel.recieverUser = ReceiverUser(userID: user.uid, userEmail: user.email)
                            print("reciever: \(chatViewModel.recieverUser)")
//                            chatViewModel.startListening()
                        }
                }
            }
            .background(Color.clear)
            
            Spacer()
        }
        .alert("Error", isPresented: $isAlertShown, actions: {
        }, message: {
            Text(alertMessage)
        })
        .sheet(
            isPresented: $isUserSelected,
        ) {
            ChatView()
                .environmentObject(chatViewModel)
        }
        .task {
            await chatViewModel.fetchAllUsers()
        }
    }
}
