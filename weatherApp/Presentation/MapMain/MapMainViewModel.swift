//
//  MapMainViewModel.swift
//  weatherApp
//
//  Created by Narmin Baghirova on 17.06.26.
//

import Combine
import CoreLocation
import MapKit
import SwiftUI

@MainActor
final class MapMainViewModel: ObservableObject {
    private var cancellables = Set<AnyCancellable>()
    private let client = NetworkClient()
    private let locationManager = LocationManager()
    private let defaultZoomLevel = 0.05

    let defaultLocation = CLLocationCoordinate2D(
        latitude: 40.4092,
        longitude: 49.8670
    )

    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var locAuthStatus: LocAuthStatus = .notDetermined
    @Published var userLocation: CLLocationCoordinate2D?
    @Published var zoomLevel: Double
    @Published var temp: Double?
    @Published var locationName: String?
    @Published var weatherDesc: WeatherDescription?

    @Published var selectedLocation = Location(
        id: UUID(),
        name: "",
        description: "",
        latitude: 0,
        longitude: 0
    )

    init() {
        zoomLevel = defaultZoomLevel

        locationManager.$authorizationStatus
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                self?.locAuthStatus = status
            }
            .store(in: &cancellables)

        locationManager.$lastKnownLocation
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] coordinate in
                guard let self else { return }

                userLocation = coordinate
                selectedLocation.latitude = coordinate.latitude
                selectedLocation.longitude = coordinate.longitude
            }
            .store(in: &cancellables)

        locationManager.$errorMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] message in
                guard let message else { return }
                self?.errorMessage = message
            }
            .store(in: &cancellables)
    }

    func requestUserLocation() {
        errorMessage = nil
        locationManager.requestLocation()
    }

    func zoomIn() {
        zoomLevel = max(zoomLevel / 2, 0.002)
    }

    func zoomOut() {
        zoomLevel = min(zoomLevel * 2, 6)
    }

    func getCurrentWeather(lat: Double, long: Double) async {
        isLoading = true
        errorMessage = nil

        defer {
            isLoading = false
        }

        do {
            let weather = try await client.send(
                GetCurrentForecast(lat: lat, long: long)
            )

            temp = weather.current.temperature2M
            weatherDesc = getWeatherDescription(
                from: weather.current.weatherCode
            )
        } catch ServiceError.invalidResponse(let statusCode) {
            errorMessage = "Server error: \(statusCode)"
        } catch ServiceError.decodingError {
            errorMessage = "Could not read weather data."
        } catch ServiceError.noInternet {
            errorMessage = "No internet connection."
        } catch {
            errorMessage = "Failed to load details: \(error.localizedDescription)"
        }
    }
    
    @available(iOS 26.0, *)
    func getLocationName(lat: Double, lon: Double) async {
        let location = CLLocation(latitude: lat, longitude: lon)
        
        guard let request = MKReverseGeocodingRequest(location: location) else {
            locationName = "Unknown location"
            return
        }

        do {
            let mapItems = try await request.mapItems

            
            print(mapItems)
            guard let item = mapItems.first else {
                locationName = "Unknown location"
                return
            }

            if let name = item.name {
                locationName = name
                return
            }

            locationName = item.addressRepresentations?.cityWithContext ?? "Unknown location"
        } catch {
            print("Reverse geocoding failed:", error.localizedDescription)
            return locationName = "Unknown location"
        }
    }
    
    func getLocationName(lat: Double, lon: Double) {
        let location = CLLocation(latitude: lat, longitude: lon)
        let geocoder = CLGeocoder()
        
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let error = error {
                self.locationName = "Unknown"
                return
            }
            
            if let placemark = placemarks?.first {
                let city = placemark.locality ?? ""
                let district = placemark.subLocality ?? ""
                let country = placemark.country ?? ""
                
                var loc = ""
                
                if country.isEmpty == true {
                    loc = "Unknown"
                } else if district.isEmpty == false {
                    loc = [district, city].joined(separator: ", ")
                } else if city.isEmpty == false {
                    loc = [city, country].joined(separator: ", ")
                } else {
                    loc = country
                }
                
                self.locationName = loc
            }
        }
    }
    
    func getWeatherDescription(from code: Int) -> WeatherDescription {
        switch code {
        case 0:
            return WeatherDescription(
                description: "Clear sky",
                iconName: "sun.min",
                iconColor: Color.yellow
            )
        case 1:
            return WeatherDescription(
                description: "Mainly clear",
                iconName: "sun.haze",
                iconColor: Color.white
            )
        case 2:
            return WeatherDescription(
                description: "Partly cloudy",
                iconName: "cloud.sun",
                iconColor: Color.cloudy
            )
        case 3:
            return WeatherDescription(
                description: "Overcast",
                iconName: "cloud",
                iconColor: Color.cloudy
            )
        case 45:
            return WeatherDescription(
                description: "Fog",
                iconName: "smoke",
                iconColor: Color.cloudy
            )
        case 48:
            return WeatherDescription(
                description: "Depositing rime fog",
                iconName: "cloud.fog",
                iconColor: Color.cloudy
            )
        case 51:
            return WeatherDescription(
                description: "Light drizzle",
                iconName: "cloud.drizzle",
                iconColor: Color.cloudy
            )
        case 53:
            return WeatherDescription(
                description: "Moderate drizzle",
                iconName: "cloud.drizzle",
                iconColor: Color.cloudy
            )
        case 55:
            return WeatherDescription(
                description: "Dense drizzle",
                iconName: "cloud.drizzle",
                iconColor: Color.cloudy
            )
        case 56:
            return WeatherDescription(
                description: "Light freezing drizzle",
                iconName: "cloud.drizzle",
                iconColor: Color.cloudy
            )
        case 57:
            return WeatherDescription(
                description: "Dense freezing drizzle",
                iconName: "cloud.drizzle",
                iconColor: Color.cloudy
            )
        case 61:
            return WeatherDescription(
                description: "Slight rain",
                iconName: "cloud.rain",
                iconColor: Color.cloudy
            )
        case 63:
            return WeatherDescription(
                description: "Moderate rain",
                iconName: "cloud.rain",
                iconColor: Color.cloudy
            )
        case 65:
            return WeatherDescription(
                description: "Heavy rain",
                iconName: "cloud.heavyrain",
                iconColor: Color.cloudy
            )
        case 66:
            return WeatherDescription(
                description: "Light freezing rain",
                iconName: "cloud.rain",
                iconColor: Color.cloudy
            )
        case 67:
            return WeatherDescription(
                description: "Heavy freezing rain",
                iconName: "cloud.heavyrain",
                iconColor: Color.cloudy
            )
        case 71:
            return WeatherDescription(
                description: "Slight snow fall",
                iconName: "snowflake",
                iconColor: Color.white
            )
        case 73:
            return WeatherDescription(
                description: "Moderate snow fall",
                iconName: "snowflake",
                iconColor: Color.white
            )
        case 75:
            return WeatherDescription(
                description: "Heavy snow fall",
                iconName: "snowflake",
                iconColor: Color.white
            )
        case 77:
            return WeatherDescription(
                description: "Snow grains",
                iconName: "cloud.hail",
                iconColor: Color.white
            )
        case 80:
            return WeatherDescription(
                description: "Slight rain showers",
                iconName: "cloud.heavyrain",
                iconColor: Color.cloudy
            )
        case 81:
            return WeatherDescription(
                description: "Moderate rain showers",
                iconName: "cloud.heavyrain",
                iconColor: Color.cloudy
            )
        case 82:
            return WeatherDescription(
                description: "Violent rain showers",
                iconName: "cloud.heavyrain",
                iconColor: Color.cloudy
            )
        case 85:
            return WeatherDescription(
                description: "Slight snow showers",
                iconName: "cloud.snow",
                iconColor: Color.white
            )
        case 86:
            return WeatherDescription(
                description: "Heavy snow showers",
                iconName: "cloud.snow",
                iconColor: Color.white
            )
        case 95:
            return WeatherDescription(
                description: "Thunderstorm",
                iconName: "cloud.bolt",
                iconColor: Color.cloudy
            )
        case 96:
            return WeatherDescription(
                description: "Thunderstorm with slight hail",
                iconName: "cloud.bolt.rain",
                iconColor: Color.cloudy
            )
        case 99:
            return WeatherDescription(
                description: "Thunderstorm with heavy hail",
                iconName: "cloud.bolt.rain",
                iconColor: Color.cloudy
            )
        default:
            return WeatherDescription(
                description: "Unknown",
                iconName: "degreesign.celsius",
                iconColor: Color.white
            )
        }
    }
}


