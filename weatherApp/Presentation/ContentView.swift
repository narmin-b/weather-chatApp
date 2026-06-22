//
//  ContentView.swift
//  weatherApp
//
//  Created by Narmin Baghirova on 17.06.26.
//

import SwiftUI

struct ContentView: View {
    private let locationService = LocationService()
    private var getUserLocationUseCase: GetUserLocationUseCase
    private var mapViewModel: MapMainViewModel

    init() {
        getUserLocationUseCase = GetUserLocationUseCase(locationService: locationService)
        mapViewModel = MapMainViewModel(getUserLocationUseCase: getUserLocationUseCase)
    }

    var body: some View {
        MapView(viewModel: mapViewModel)
    }
}
