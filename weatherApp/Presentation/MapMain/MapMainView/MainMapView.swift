//
//  MainMapView.swift
//  weatherApp
//
//  Created by Narmin Baghirova on 17.06.26.
//

import SwiftUI
import MapKit
import CoreLocation
import Combine


struct MainMapView: View {
    @StateObject private var viewModel = MapMainViewModel()
    
    @State private var position: MapCameraPosition
    @State private var newTapDetected = false
    @State private var isSheetPresented = false
    @State private var sheetHeight: CGFloat = .zero
    @State private var isAlertShown = false
    @State private var alertMessage = ""
    
    init() {
        let region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(
                latitude: 40.4092,
                longitude: 49.8670
            ),
            span: MKCoordinateSpan(
                latitudeDelta: 0.05,
                longitudeDelta: 0.05
            )
        )
        
        _position = State(initialValue: .region(region))
    }
    
    private var currentMapCenter: CLLocationCoordinate2D {
        CLLocationCoordinate2D(
            latitude: viewModel.selectedLocation.latitude,
            longitude: viewModel.selectedLocation.longitude
        )
    }
    
    var body: some View {
        ZStack {
            mapView
            
            VStack {
                Spacer()
                
                HStack {
                    Spacer()
                    
                    VStack {
                        ActionButton(iconName: "plus.magnifyingglass") {
                            viewModel.zoomIn()
                            updateMapPosition(
                                center: currentMapCenter
                            )
                        }
                        
                        ActionButton(iconName: "minus.magnifyingglass") {
                            viewModel.zoomOut()
                            updateMapPosition(
                                center: currentMapCenter
                            )
                        }
                        
                        ActionButton(iconName: "location.circle") {
                            viewModel.requestUserLocation()
                        }
                    }
                    .padding()
                }
                .padding(
                    .bottom,
                    isSheetPresented ? sheetHeight - 50 : sheetHeight
                )
            }
        }
        .onReceive(
            viewModel.$userLocation.compactMap { $0 }
        ) { coordinate in
            viewModel.selectedLocation = Location(
                id: UUID(),
                name: "Current location",
                description: "",
                latitude: coordinate.latitude,
                longitude: coordinate.longitude
            )
            //            showLocation(coordinate)
        }
        .onReceive(
            viewModel.$errorMessage.compactMap { $0 }
        ) { message in
            alertMessage = message
            isAlertShown = true
            isSheetPresented = false
        }
        .alert("Error", isPresented: $isAlertShown) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
        .sheet(isPresented: $isSheetPresented) {
            WeatherSheet(
                isLoading: $viewModel.isLoading,
                isPresented: $isSheetPresented,
                temp: $viewModel.temp,
                loc: $viewModel.locationName,
                weatherDescription: $viewModel.weatherDesc,
                errorMessage: $viewModel.errorMessage
            )
            .modifier(GetHeightModifier(height: $sheetHeight))
            .presentationDetents([.height(sheetHeight)])
            .presentationBackgroundInteraction(.enabled)
            .presentationDragIndicator(.visible)
            .presentationBackground(Color.infoBG)
            .onDisappear {
                isSheetPresented = false
            }
        }
    }

    private func showLocation(
        _ coordinate: CLLocationCoordinate2D
    ) {
        newTapDetected = true
        updateMapPosition(center: coordinate)
        
        Task {
            await viewModel.getCurrentWeather(
                lat: coordinate.latitude,
                long: coordinate.longitude
            )
            
            await viewModel.getLocationName(
                lat: coordinate.latitude,
                lon: coordinate.longitude
            )
        }
        
        isSheetPresented = true
    }
    
    private func updateMapPosition(
        center: CLLocationCoordinate2D
    ) {
        position = .region(
            MKCoordinateRegion(
                center: center,
                span: MKCoordinateSpan(
                    latitudeDelta: viewModel.zoomLevel,
                    longitudeDelta: viewModel.zoomLevel
                )
            )
        )
    }
    
    //MARK: Components
    var mapView: some View {
        MapReader { proxy in
            Map(position: $position) {
                if newTapDetected {
                    Marker(
                        viewModel.selectedLocation.name,
                        coordinate: CLLocationCoordinate2D(
                            latitude: viewModel.selectedLocation.latitude,
                            longitude: viewModel.selectedLocation.longitude
                        )
                    )
                    .tint(.blue)
                }
            }
            .onTapGesture { tapPosition in
                guard let coordinate = proxy.convert(
                    tapPosition,
                    from: .local
                ) else {
                    return
                }
                
                viewModel.selectedLocation = Location(
                    id: UUID(),
                    name: "Location",
                    description: "",
                    latitude: coordinate.latitude,
                    longitude: coordinate.longitude
                )
                
                showLocation(coordinate)
            }
            .ignoresSafeArea()
        }
    }
}
