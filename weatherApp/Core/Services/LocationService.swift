////
////  LocationService.swift
////  weatherApp
////
////  Created by Narmin Baghirova on 17.06.26.
////
//
//import CoreLocation
//import Combine
//
//class LocationService: NSObject, ObservableObject, CLLocationManagerDelegate {
//    private let locationManager = CLLocationManager()
//    @Published var userLocation: CLLocationCoordinate2D?
//
//    override init() {
//        super.init()
//        locationManager.delegate = self
//        locationManager.desiredAccuracy = kCLLocationAccuracyBest
//        locationManager.requestWhenInUseAuthorization()
//        locationManager.startUpdatingLocation()
//    }
//
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        guard let location = locations.first else { return }
//        userLocation = location.coordinate
//    }
//}
