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
    
    @Namespace var attachmentViewerAnimation
    
    let onLogIn: () -> Void
    
    var body: some View {
        ZStack {
            Color.infoBG
                .ignoresSafeArea()
                .opacity(0.5)
            
            VStack(spacing: 2) {
                Text( isLogin ? "To continue with chat,\n please log in" : "To start a chat,\n please register")
                    .font(.system(size: 28, weight: .semibold))
                    .multilineTextAlignment(.center)
                    .padding(.top, 64)
                
                Spacer()
                
                ZStack(alignment: .leading) {
                    Text("Email")
                        .foregroundStyle(email.isEmpty ? .gray : .primary)
                        .padding(.leading, 16)
                        .font(.system(size: 16))
                        .scaleEffect(email.isEmpty ? 1 : 0.85, anchor: .leading)
                        .offset(y: email.isEmpty ? 0 : -32)
                    TextField("", text: $email)
                        .padding(12)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.black, lineWidth: 1)
                        )
                }
                .padding(.vertical, 12)
                .animation(.spring(response: 0.3, dampingFraction: 0.85), value: email.isEmpty)
               
                ZStack(alignment: .leading) {
                    Text("Password")
                        .foregroundStyle(password.isEmpty ? .gray : .primary)
                        .padding(.leading, 16)
                        .font(.system(size: 16))
                        .scaleEffect(password.isEmpty ? 1 : 0.85, anchor: .leading)
                        .offset(y: password.isEmpty ? 0 : -32)
                    SecureField("", text: $password)
                        .padding(12)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.black, lineWidth: 1)
                        )
                }
                .padding(.vertical, 12)
                .animation(.spring(response: 0.3, dampingFraction: 0.85), value: password.isEmpty)
                
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
                    .padding(12)
                    .background(Color.cloudy)
                    .foregroundStyle(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.top, 12)
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
                    .padding(12)
                    .background(Color.cloudy)
                    .foregroundStyle(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.top, 12)
                }
                
                HStack(spacing: 2) {
                    if isLogin {
                        Text("Don't have an account? ")
                        Text("Register")
                            .foregroundStyle(.cloudy)
                            .onTapGesture {
                                isLogin.toggle()
                            }
                    } else {
                        Text("Already have an account? ")
                        Text("Login")
                            .foregroundStyle(.cloudy)
                            .onTapGesture {
                                isLogin.toggle()
                            }
                    }
                }
                .padding(.top, 12)
                .frame(maxWidth: .infinity, alignment: .center)
                
                Spacer()
            }
            .padding()
        }
        .alert("Error", isPresented: $isAlertShown, actions: {
        }, message: {
            Text(alertMessage)
        })
    }
}
