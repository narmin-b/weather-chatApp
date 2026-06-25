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
struct WeatherApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self)
    private var delegate
    
    var body: some Scene {
        WindowGroup {
            CoordinatorView()
        }
    }
}

