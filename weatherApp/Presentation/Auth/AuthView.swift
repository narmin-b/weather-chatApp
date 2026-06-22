//
//  AuthView.swift
//  weatherApp
//
//  Created by Narmin Baghirova on 19.06.26.
//

import SwiftUI

struct AuthView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isLogin: Bool = false
    @State private var isAlertShown: Bool = false
    @State private var alertMessage: String = ""
    let onLogIn: () -> Void

    var body: some View {
        ZStack {
            Color.gray
                .ignoresSafeArea()
                .opacity(0.5)
            
            VStack {
                TextField("Email", text: $email)
                    .textFieldStyle(.roundedBorder)
                SecureField("Password", text: $password)
                    .textFieldStyle(.roundedBorder)
                
                if isLogin {
                    Button("Login") {
                        authViewModel.login(email: email, password: password) { error in
                            if let error = error {
                                isAlertShown = true
                                alertMessage = "Login failed! \(error.localizedDescription)"
                            } else {
                                onLogIn()
                            }
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                }
                else {
                    Button("Create an Account") {
                        authViewModel.createAcc(email: email, password: password) { error in
                            if let error = error {
                                isAlertShown = true
                                alertMessage = "Register failed! \(error.localizedDescription)"
                            } else {
                                onLogIn()
                            }
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                }
                
                HStack {
                    if isLogin {
                        Text("Don't have an account? ")
                        Text("Register")
                            .foregroundStyle(.blue)
                            .onTapGesture {
                                isLogin.toggle()
                            }
                    } else {
                        Text("Already have an account? ")
                        Text("Login")
                            .foregroundStyle(.blue)
                            .onTapGesture {
                                isLogin.toggle()
                            }
                    }
                    
                }.frame(maxWidth: .infinity, alignment: .center)
            }
            .padding()
        }
        .alert("Error", isPresented: $isAlertShown, actions: {
        }, message: {
            Text(alertMessage)
        })
    }
}
