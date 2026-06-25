//
//  CoordinatorView.swift
//  weatherApp
//
//  Created by Narmin Baghirova on 25.06.26.
//

import SwiftUI
import Combine

struct CoordinatorView: View {
    @StateObject private var coordinator = AppCoordinator()
    @StateObject private var authViewModel = AuthViewModel()

    var body: some View {
        NavigationStack(path: $coordinator.path) {
            coordinator.build(rootPage)
                .navigationDestination(for: AppPage.self) { page in
                    coordinator.build(page)
                }
        }
        .environmentObject(coordinator)
        .environmentObject(authViewModel)
    }

    private var rootPage: AppPage {
        return .main
    }
}
