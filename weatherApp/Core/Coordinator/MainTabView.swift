//
//  MainTabView.swift
//  weatherApp
//
//  Created by Narmin Baghirova on 25.06.26.
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            MainMapView()
                .tabItem {
                    Label("Map", systemImage: "map.fill")
                }

            AuthView()
                .tabItem {
                    Label("Chat", systemImage: "message.fill")
                }
        }
    }
}
