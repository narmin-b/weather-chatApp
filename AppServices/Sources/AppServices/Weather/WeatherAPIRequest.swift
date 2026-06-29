//
//  WeatherAPIRequest.swift
//  AppServices
//
//  Created by Narmin Baghirova on 28.06.26.
//

import Foundation

public protocol WeatherAPIRequest: APIRequest {
    var endpoint: WeatherEndpoint { get }
}

public extension WeatherAPIRequest {
    var urlRequest: URLRequest {
        get throws {
            var components = URLComponents()
            components.scheme = "https"
            components.host = "api.open-meteo.com"
            components.path = endpoint.path
            components.queryItems = endpoint.queryItems

            guard let url = components.url else {
                throw ServiceError.invalidURL
            }

            var request = URLRequest(url: url)
            request.httpMethod = endpoint.method.rawValue
            request.timeoutInterval = 30

            return request
        }
    }
}
