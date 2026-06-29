//
//  WeatherEndpoint.swift
//  AppServices
//
//  Created by Narmin Baghirova on 28.06.26.
//

import Foundation

public enum WeatherEndpoint {
    case hourly(latitude: Double, longitude: Double)
    case current(latitude: Double, longitude: Double)
    case hourlyAndCurrent(latitude: Double, longitude: Double)

    public var path: String {
        "/v1/forecast"
    }

    public var method: HTTPMethod {
        .GET
    }

    public var queryItems: [URLQueryItem] {
        let coordinateItems = [
            URLQueryItem(
                name: "latitude",
                value: String(latitude)
            ),
            URLQueryItem(
                name: "longitude",
                value: String(longitude)
            )
        ]

        switch self {
        case .hourly:
            return coordinateItems + [
                URLQueryItem(
                    name: "hourly",
                    value: "temperature_2m,weather_code"
                ),
                URLQueryItem(
                    name: "format",
                    value: "json"
                )
            ]

        case .current:
            return coordinateItems + [
                URLQueryItem(
                    name: "current",
                    value: """
                    temperature_2m,relative_humidity_2m,weather_code,\
                    wind_speed_10m,precipitation
                    """
                ),
                URLQueryItem(
                    name: "format",
                    value: "json"
                )
            ]

        case .hourlyAndCurrent:
            return coordinateItems + [
                URLQueryItem(
                    name: "current",
                    value: """
                    temperature_2m,relative_humidity_2m,weather_code,\
                    wind_speed_10m,precipitation
                    """
                ),
                URLQueryItem(
                    name: "hourly",
                    value: "temperature_2m,weather_code"
                ),
                URLQueryItem(
                    name: "format",
                    value: "json"
                )
            ]
        }
    }

    private var latitude: Double {
        switch self {
        case .hourly(let latitude, _),
             .current(let latitude, _),
             .hourlyAndCurrent(let latitude, _):
            return latitude
        }
    }

    private var longitude: Double {
        switch self {
        case .hourly(_, let longitude),
             .current(_, let longitude),
             .hourlyAndCurrent(_, let longitude):
            return longitude
        }
    }
}
