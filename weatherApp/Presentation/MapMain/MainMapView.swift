//
//  MainMapView.swift
//  weatherApp
//
//  Created by Narmin Baghirova on 17.06.26.
//

import SwiftUI
import MapKit
import CoreLocation

struct Location: Codable, Equatable, Identifiable {
    let id: UUID
    var name: String
    var description: String
    var latitude: Double
    var longitude: Double
}

struct MainMapView: View {
    @StateObject private var viewModel = MapMainViewModel()
    @State private var locations = [Location]()
    @State private var position: MapCameraPosition
    @State private var newTapDetected: Bool = false
    @State private var isSheetPresented = false
    @State private var sheetHeight: CGFloat = .zero
    @State private var newLocation: Location = Location(
        id: UUID(),
        name: "",
        description: "",
        latitude: 0,
        longitude: 0
    )
    
    init() {
        let defaultRegion = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 40.4092, longitude: 49.8670),
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        )
        
        _position = State(initialValue: .region(defaultRegion))
    }
    
    var body: some View {
        ZStack {
            MapReader { proxy in
                Map(position: $position) {
                    ForEach(locations) { location in
                        Marker(
                            location.name,
                            coordinate: CLLocationCoordinate2D(
                                latitude: location.latitude,
                                longitude: location.longitude
                            )
                        )
                    }
                    if newTapDetected {
                        Marker(
                            newLocation.name,
                            coordinate: CLLocationCoordinate2D(
                                latitude: newLocation.latitude,
                                longitude: newLocation.longitude
                            )
                        )
                        .tint(.blue)
                    }
                }
                .onTapGesture { position in
                    if let coordinate = proxy.convert(position, from: .local) {
                        newLocation = Location(id: UUID(), name: "New location", description: "", latitude: coordinate.latitude, longitude: coordinate.longitude)
                        newTapDetected = true
                        
                        Task {
                            await viewModel.getCurrentWeather(lat: newLocation.latitude, long: newLocation.longitude)
                            await viewModel.getLocationName(lat: newLocation.latitude, lon: newLocation.longitude)
                        }
                        
                        isSheetPresented = true
                    }
                }
                .ignoresSafeArea()
            }
            .onAppear {
                position = .region(
                    MKCoordinateRegion(
                        center: viewModel.userLocation ?? CLLocationCoordinate2D(
                            latitude: 40.4092,
                            longitude: 49.8670
                        ),
                        span: MKCoordinateSpan(
                            latitudeDelta: viewModel.zoomLevel,
                            longitudeDelta: viewModel.zoomLevel
                        )
                    )
                )
            }
            
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    VStack {
                        Button(action: {
                            viewModel.zoomIn()
                            updateMapPosition()
                        }) {
                            Image(systemName: "plus.magnifyingglass")
                                .padding()
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(radius: 4)
                        }
                        
                        Button(action: {
                            viewModel.zoomOut()
                            updateMapPosition()
                        }) {
                            Image(systemName: "minus.magnifyingglass")
                                .padding()
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(radius: 4)
                        }
                        
//                        Button(action: {
//                            locations.append(newLocation)
//                        }) {
//                            Image(systemName: "plus")
//                                .padding()
//                                .background(Color.white)
//                                .clipShape(Circle())
//                                .shadow(radius: 4)
//                        }
//                        .onAppear {
//                            newTapDetected = false
//                            isSheetPresented = false
//                            
//                        }
                    }
                    .padding()
                }
                .padding(.bottom, isSheetPresented ? sheetHeight-50 : sheetHeight)
            }
        }
        .sheet(isPresented: $isSheetPresented) {
            WeatherSheet(isPresented: $isSheetPresented, temp: $viewModel.temp, loc: $viewModel.locationName, weatherDescription: $viewModel.weatherDesc)
                .modifier(GetHeightModifier(height: $sheetHeight))
                .presentationDetents([.height(sheetHeight)])
                .presentationBackgroundInteraction(.enabled)
                .presentationDragIndicator(.visible)
                .presentationBackground(Color.infoBG)
                .onDisappear {
                    withAnimation(.smooth) {
                        sheetHeight = 0
                    }
                    isSheetPresented = false
                }
        }
    }
    
   
    private func updateMapPosition() {
        position = .region(
            MKCoordinateRegion(
                center: viewModel.userLocation ?? CLLocationCoordinate2D(
                    latitude: newLocation.latitude,
                    longitude: newLocation.longitude
                ),
                span: MKCoordinateSpan(
                    latitudeDelta: viewModel.zoomLevel,
                    longitudeDelta: viewModel.zoomLevel
                )
            )
        )
    }    
}

struct UserLocationAnnotation: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    let title: String?
}
