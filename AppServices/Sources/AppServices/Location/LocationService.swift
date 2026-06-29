//
//  LocationService.swift
//  weatherApp
//
//  Created by Narmin Baghirova on 17.06.26.
//

import CoreLocation
import Combine

public enum LocAuthStatus {
    case notDetermined
    case restricted
    case denied
    case authorizedAlways
    case authorizedWhenInUse
}

public final class LocationManager: NSObject, ObservableObject {
    @Published public private(set) var authorizationStatus: LocAuthStatus = .notDetermined
    @Published public private(set) var lastKnownLocation: CLLocationCoordinate2D?
    @Published public private(set) var errorMessage: String?

    private let manager = CLLocationManager()
    private var hasRequestedAuthorization = false

    public override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }

    public func requestLocation() {
        handleAuthorization(manager.authorizationStatus)
    }

    public func handleAuthorization(_ status: CLAuthorizationStatus) {
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
    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        handleAuthorization(manager.authorizationStatus)
    }

    public func locationManager(
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

    public func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: Error
    ) {
        errorMessage = "Could not get location: \(error.localizedDescription)"
    }
}
