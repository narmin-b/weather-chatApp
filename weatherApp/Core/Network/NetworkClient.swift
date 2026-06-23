//
//  NetworkClient.swift
//  weatherApp
//
//  Created by Narmin Baghirova on 17.06.26.
//

import Foundation

final class NetworkClient {
    func send<T: APIRequest>(_ request: T) async throws -> T.Response {
        guard let url = request.url else {
            throw ServiceError.invalidURL
        }

        var urlRequest = URLRequest(url: url)
        
        urlRequest.httpMethod = request.endpoint.method.rawValue

        let (data, response): (Data, URLResponse)
        do {
            print("LOG: sending request: \(urlRequest)")
            (data, response) = try await URLSession.shared.data(for: urlRequest)
            print("LOG: received data: \(response)")
        } catch let urlError as URLError {
            if urlError.code == .notConnectedToInternet {
                throw ServiceError.noInternet
            } else {
                throw ServiceError.unknown(urlError)
            }
        } catch {
            throw ServiceError.unknown(error)
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ServiceError.unknown(NSError(domain: "Invalid response", code: 0))
        }

        guard (200..<300).contains(httpResponse.statusCode) else {
            throw ServiceError.invalidResponse(statusCode: httpResponse.statusCode)
        }

        do {
            return try JSONDecoder().decode(T.Response.self, from: data)
        } catch {
            print("LOG: decoding error")
            throw ServiceError.decodingError
        }
    }
}
