//
//  LocationService.swift
//  weatherApp
//
//  Created by Narmin Baghirova on 17.06.26.
//

import CoreLocation
import Combine

enum LocAuthStatus {
    case notDetermined
    case restricted
    case denied
    case authorizedAlways
    case authorizedWhenInUse
}

final class LocationManager: NSObject, ObservableObject {
    @Published private(set) var authorizationStatus: LocAuthStatus = .notDetermined
    @Published private(set) var lastKnownLocation: CLLocationCoordinate2D?
    @Published private(set) var errorMessage: String?

    private let manager = CLLocationManager()
    private var hasRequestedAuthorization = false

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }

    func requestLocation() {
        handleAuthorization(manager.authorizationStatus)
    }

    private func handleAuthorization(_ status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            authorizationStatus = .notDetermined

            guard !hasRequestedAuthorization else { return }

            hasRequestedAuthorization = true
            manager.requestWhenInUseAuthorization()

        case .restricted:
            authorizationStatus = .restricted
            errorMessage = "Location access is restricted."

        case .denied:
            authorizationStatus = .denied
            errorMessage = "Location access is denied. Enable it in Settings."

        case .authorizedAlways:
            authorizationStatus = .authorizedAlways
            errorMessage = nil
            manager.requestLocation()

        case .authorizedWhenInUse:
            authorizationStatus = .authorizedWhenInUse
            errorMessage = nil
            manager.requestLocation()

        @unknown default:
            authorizationStatus = .denied
            errorMessage = "Unable to access your location."
        }
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        handleAuthorization(manager.authorizationStatus)
    }

    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        guard let coordinate = locations.last?.coordinate else {
            errorMessage = "No location was received."
            return
        }

        lastKnownLocation = coordinate
        errorMessage = nil
    }

    func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: Error
    ) {
        errorMessage = "Could not get location: \(error.localizedDescription)"
    }
}
