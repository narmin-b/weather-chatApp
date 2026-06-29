//
//  ServiceError.swift
//  weatherApp
//
//  Created by Narmin Baghirova on 17.06.26.
//

import Foundation

public enum ServiceError: LocalizedError {
    case noInternet
    case invalidURL
    case invalidResponse
    case invalidResponseStatus(statusCode: Int)
    case decodingError(Error)
    case missingAuthenticatedUser
    case unknown(Error)

    public var errorDescription: String? {
        switch self {
        case .noInternet:
            return "No internet connection."

        case .invalidURL:
            return "The request URL is invalid."

        case .invalidResponse:
            return "The server returned an invalid response."

        case .invalidResponseStatus(let statusCode):
            return "The server returned status code \(statusCode)."

        case .decodingError(let error):
            return "Could not decode the response: \(error.localizedDescription)"

        case .missingAuthenticatedUser:
            return "Firebase did not return an authenticated user."

        case .unknown(let error):
            return error.localizedDescription
        }
    }
}
