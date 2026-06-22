//
//  weatherApp.swift
//  weatherApp
//
//  Created by Narmin Baghirova on 17.06.26.
//

import SwiftUI
import Firebase

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
  }
}

@main
struct weatherApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var authViewModel = AuthViewModel()
    @State private var isLoggedIn: Bool = false
    
    var body: some Scene {
        WindowGroup {
            TabView {
                Tab("Map", systemImage: "map.fill") {
                    MainMapView()
                }
                
                if isLoggedIn {
                    Tab("Chat", systemImage: "ellipsis.message.fill") {
                        UsersListView {
                            isLoggedIn = false
                        }
                    }
                } else {
                    Tab("Auth", systemImage: "person") {
                        AuthView {
                            isLoggedIn = true
                        }
                    }
                }
            }
            .environmentObject(authViewModel)
        }
    }
}
