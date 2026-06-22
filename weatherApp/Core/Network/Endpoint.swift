//
//  Endpoint.swift
//  weatherApp
//
//  Created by Narmin Baghirova on 17.06.26.
//

import Foundation

enum HTTPMethod: String {
    case GET, POST, PUT, DELETE
}

enum Endpoint {
    case hourly(lat: String, long: String)
    case current(lat: String, long: String)
    case hourlyAndCurrent(lat: String, long: String)
    
    var path: String {
        "/v1/forecast"
    }
    
    var method: HTTPMethod {
        switch self {
        case .hourly(_, _):
            return .GET
        case .current(_, _):
            return .GET
        case .hourlyAndCurrent(_, _):
            return .GET
        }
    }
    
    var queryItems: [URLQueryItem] {
        switch self {
        case .hourly(let lat, let long):
            return [
                URLQueryItem(name: "latitude", value: lat),
                URLQueryItem(name: "longitude", value: long),
                URLQueryItem(name: "hourly", value: "temperature_2m,weather_code"),
                URLQueryItem(name: "format", value: "json")
            ]
            
        case .current(let lat, let long):
            return [
                URLQueryItem(name: "latitude", value: lat),
                URLQueryItem(name: "longitude", value: long),
                URLQueryItem(name: "current", value: "temperature_2m,relative_humidity_2m,weather_code,wind_speed_10m,precipitation"),
                URLQueryItem(name: "format", value: "json")
            ]
            
        case .hourlyAndCurrent(let lat, let long):
            return [
                URLQueryItem(name: "latitude", value: lat),
                URLQueryItem(name: "longitude", value: long),
                URLQueryItem(name: "current", value: "temperature_2m,relative_humidity_2m,weather_code,wind_speed_10m,precipitation,temperature_2m"),
                URLQueryItem(name: "hourly", value: "temperature_2m,weather_code"),
                URLQueryItem(name: "format", value: "json")
            ]
        }
    }
}
