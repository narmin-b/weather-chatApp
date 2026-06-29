//
//  APIRequest.swift
//  weatherApp
//
//  Created by Narmin Baghirova on 17.06.26.
//

import Foundation

public protocol APIRequest {
    associatedtype Response: Decodable

    var urlRequest: URLRequest { get throws }
}
