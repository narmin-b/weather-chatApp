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
import AppServices

@MainActor
final class MapMainViewModel: ObservableObject {
    private var cancellables = Set<AnyCancellable>()
    private let client: NetworkClient
    private let locationManager: LocationManager
    private let defaultZoomLevel = 0.05

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

    init(
        client: NetworkClient? = nil,
        locationManager: LocationManager? = nil
    ) {
        self.client = client ?? NetworkClient()
        self.locationManager = locationManager ?? LocationManager()
        self.zoomLevel = defaultZoomLevel

        observeLocationManager()
    }

    private func observeLocationManager() {
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

    func getCurrentWeather(lat: Double,long: Double) async {
        isLoading = true
        errorMessage = nil

        defer {
            isLoading = false
        }

        do {
            let forecast = try await client.send(
                GetCurrentForecast(
                    latitude: lat,
                    longitude: long
                )
            )

            guard
                let temperature = forecast.currentTemperature,
                let weatherCode = forecast.currentWeatherCode
            else {
                throw ServiceError.invalidResponse
            }

            temp = temperature
            weatherDesc = getWeatherDescription(from: weatherCode)

        } catch ServiceError.invalidResponseStatus(let statusCode) {
            errorMessage = "Server error: \(statusCode)"

        } catch ServiceError.decodingError(_) {
            errorMessage = "Could not read weather data."

        } catch ServiceError.noInternet {
            errorMessage = "No internet connection."

        } catch {
            errorMessage = "Failed to load details: \(error.localizedDescription)"
        }
    }

    func getLocationName(lat: Double, lon: Double) async {
        let location = CLLocation(
            latitude: lat,
            longitude: lon
        )

        if #available(iOS 26.0, *) {
            await reverseGeocodeWithMapKit(location)
        } else {
            await reverseGeocodeWithCoreLocation(location)
        }
    }

    @available(iOS 26.0, *)
    private func reverseGeocodeWithMapKit(_ location: CLLocation) async {
        guard let request = MKReverseGeocodingRequest(
            location: location
        ) else {
            locationName = "Unknown location"
            return
        }

        do {
            let mapItems = try await request.mapItems

            guard let item = mapItems.first else {
                locationName = "Unknown location"
                return
            }

            if let name = item.name, !name.isEmpty {
                locationName = name
            } else {
                locationName =
                    item.addressRepresentations?.cityWithContext
                    ?? "Unknown location"
            }
        } catch {
            locationName = "Unknown location"
        }
    }

    private func reverseGeocodeWithCoreLocation(_ location: CLLocation) async {
        do {
            let placemarks = try await CLGeocoder()
                .reverseGeocodeLocation(location)

            guard let placemark = placemarks.first else {
                locationName = "Unknown location"
                return
            }

            locationName = formatLocationName(
                from: placemark
            )
        } catch {
            locationName = "Unknown location"
        }
    }

    private func formatLocationName(from placemark: CLPlacemark) -> String {
        let district = placemark.subLocality ?? ""
        let city = placemark.locality ?? ""
        let country = placemark.country ?? ""

        if !district.isEmpty && !city.isEmpty {
            return "\(district), \(city)"
        }

        if !city.isEmpty && !country.isEmpty {
            return "\(city), \(country)"
        }

        if !city.isEmpty {
            return city
        }

        if !country.isEmpty {
            return country
        }

        return "Unknown location"
    }

    func getWeatherDescription(from code: Int) -> WeatherDescription {
        let description: String
        let iconName: String
        let iconColor: Color

        switch code {
        case 0:
            description = "Clear sky"
            iconName = "sun.min"
            iconColor = .yellow

        case 1:
            description = "Mainly clear"
            iconName = "sun.haze"
            iconColor = .white

        case 2:
            description = "Partly cloudy"
            iconName = "cloud.sun"
            iconColor = .cloudy

        case 3:
            description = "Overcast"
            iconName = "cloud"
            iconColor = .cloudy

        case 45:
            description = "Fog"
            iconName = "smoke"
            iconColor = .cloudy

        case 48:
            description = "Depositing rime fog"
            iconName = "cloud.fog"
            iconColor = .cloudy

        case 51:
            description = "Light drizzle"
            iconName = "cloud.drizzle"
            iconColor = .cloudy

        case 53:
            description = "Moderate drizzle"
            iconName = "cloud.drizzle"
            iconColor = .cloudy

        case 55:
            description = "Dense drizzle"
            iconName = "cloud.drizzle"
            iconColor = .cloudy

        case 56:
            description = "Light freezing drizzle"
            iconName = "cloud.drizzle"
            iconColor = .cloudy

        case 57:
            description = "Dense freezing drizzle"
            iconName = "cloud.drizzle"
            iconColor = .cloudy

        case 61:
            description = "Slight rain"
            iconName = "cloud.rain"
            iconColor = .cloudy

        case 63:
            description = "Moderate rain"
            iconName = "cloud.rain"
            iconColor = .cloudy

        case 65:
            description = "Heavy rain"
            iconName = "cloud.heavyrain"
            iconColor = .cloudy

        case 66:
            description = "Light freezing rain"
            iconName = "cloud.rain"
            iconColor = .cloudy

        case 67:
            description = "Heavy freezing rain"
            iconName = "cloud.heavyrain"
            iconColor = .cloudy

        case 71:
            description = "Slight snowfall"
            iconName = "snowflake"
            iconColor = .white

        case 73:
            description = "Moderate snowfall"
            iconName = "snowflake"
            iconColor = .white

        case 75:
            description = "Heavy snowfall"
            iconName = "snowflake"
            iconColor = .white

        case 77:
            description = "Snow grains"
            iconName = "cloud.hail"
            iconColor = .white

        case 80:
            description = "Slight rain showers"
            iconName = "cloud.heavyrain"
            iconColor = .cloudy

        case 81:
            description = "Moderate rain showers"
            iconName = "cloud.heavyrain"
            iconColor = .cloudy

        case 82:
            description = "Violent rain showers"
            iconName = "cloud.heavyrain"
            iconColor = .cloudy

        case 85:
            description = "Slight snow showers"
            iconName = "cloud.snow"
            iconColor = .white

        case 86:
            description = "Heavy snow showers"
            iconName = "cloud.snow"
            iconColor = .white

        case 95:
            description = "Thunderstorm"
            iconName = "cloud.bolt"
            iconColor = .cloudy

        case 96:
            description = "Thunderstorm with slight hail"
            iconName = "cloud.bolt.rain"
            iconColor = .cloudy

        case 99:
            description = "Thunderstorm with heavy hail"
            iconName = "cloud.bolt.rain"
            iconColor = .cloudy

        default:
            description = "Unknown"
            iconName = "degreesign.celsius"
            iconColor = .white
        }

        return WeatherDescription(
            description: description,
            iconName: iconName,
            iconColor: iconColor
        )
    }
}
