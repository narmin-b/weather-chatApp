//
//  ServiceError.swift
//  weatherApp
//
//  Created by Narmin Baghirova on 17.06.26.
//

import Foundation

enum ServiceError: LocalizedError {
    case noInternet
    case invalidResponse(statusCode: Int)
    case decodingError
    case unknown(Error)
    case invalidURL

    var errorDescription: String? {
        switch self {
        case .noInternet:
            return "No internet connection."
        case .invalidResponse(let statusCode):
            return "Server returned status code \(statusCode)."
        case .decodingError:
            return "Could not decode server response."
        case .unknown(let error):
            return error.localizedDescription
        case .invalidURL:
            return "Invalid URL."
        }
    }
}
