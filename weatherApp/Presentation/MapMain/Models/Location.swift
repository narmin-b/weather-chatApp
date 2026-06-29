//
//  Location.swift
//  weatherApp
//
//  Created by Narmin Baghirova on 29.06.26.
//

import Foundation

struct Location: Codable, Equatable, Identifiable {
    let id: UUID
    var name: String
    var description: String
    var latitude: Double
    var longitude: Double
}
