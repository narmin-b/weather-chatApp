//
//  ServiceError.swift
//  weatherApp
//
//  Created by Narmin Baghirova on 17.06.26.
//

enum ServiceError: Error {
    case invalidURL
    case decodingError
    case serverError(statusCode: Int)
    case unknown(Error)
}
