//
//  NetworkClient.swift
//  weatherApp
//
//  Created by Narmin Baghirova on 17.06.26.
//

import Foundation

public final class NetworkClient {
    private let session: URLSession
    private let decoder: JSONDecoder

    public init(
        session: URLSession = .shared,
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.session = session
        self.decoder = decoder
    }
    
    @available(iOS 15.0, *)
    public func send<Request: APIRequest>(
        _ request: Request
    ) async throws -> Request.Response {
        let urlRequest = try request.urlRequest

        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await session.data(
                for: urlRequest,
                delegate: nil
            )
        } catch let error as URLError {
            switch error.code {
            case .notConnectedToInternet,
                 .networkConnectionLost,
                 .cannotConnectToHost,
                 .cannotFindHost:
                throw ServiceError.noInternet

            default:
                throw ServiceError.unknown(error)
            }
        } catch {
            throw ServiceError.unknown(error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw ServiceError.invalidResponse
        }

        guard (200..<300).contains(httpResponse.statusCode) else {
            throw ServiceError.invalidResponseStatus(
                statusCode: httpResponse.statusCode
            )
        }

        do {
            return try decoder.decode(Request.Response.self, from: data)
        } catch {
            throw ServiceError.decodingError(error)
        }
    }
}
