//
//  APIRequest.swift
//  weatherApp
//
//  Created by Narmin Baghirova on 17.06.26.
//

import Foundation

protocol APIRequest {
    associatedtype Response: Decodable
    var endpoint: Endpoint { get }
}

struct GetHourlyForecast: APIRequest {
    var lat: Double
    var long: Double
    
    typealias Response = Forecast
    
    var endpoint: Endpoint {
        .hourly(lat: String(lat), long: String(long))
    }
}

struct GetCurrentForecast: APIRequest {
    var lat: Double
    var long: Double
    
    typealias Response = Forecast
    
    var endpoint: Endpoint {
        .current(lat: String(lat), long: String(long))
    }
}

struct GetHourlyAndCurrentForecast: APIRequest {
    var lat: Double
    var long: Double
    
    typealias Response = Forecast
    
    var endpoint: Endpoint {
        .hourlyAndCurrent(lat: String(lat), long: String(long))
    }
}

extension APIRequest {
    var url: URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.open-meteo.com"
        components.path = endpoint.path
        components.queryItems = endpoint.queryItems
        
        return components.url
    }
}
