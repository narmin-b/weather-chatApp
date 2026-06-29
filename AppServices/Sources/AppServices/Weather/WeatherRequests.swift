//
//  WeatherRequests.swift.swift
//  AppServices
//
//  Created by Narmin Baghirova on 28.06.26.
//

import Foundation

public struct GetHourlyForecast: WeatherAPIRequest {
    public typealias Response = Forecast

    public let latitude: Double
    public let longitude: Double

    public init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }

    public var endpoint: WeatherEndpoint {
        .hourly(
            latitude: latitude,
            longitude: longitude
        )
    }
}

public struct GetCurrentForecast: WeatherAPIRequest {
    public typealias Response = Forecast

    public let latitude: Double
    public let longitude: Double

    public init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }

    public var endpoint: WeatherEndpoint {
        .current(
            latitude: latitude,
            longitude: longitude
        )
    }
}

public struct GetHourlyAndCurrentForecast: WeatherAPIRequest {
    public typealias Response = Forecast

    public let latitude: Double
    public let longitude: Double

    public init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }

    public var endpoint: WeatherEndpoint {
        .hourlyAndCurrent(
            latitude: latitude,
            longitude: longitude
        )
    }
}
