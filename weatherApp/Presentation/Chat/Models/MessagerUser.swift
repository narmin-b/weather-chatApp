//
//  MessagerUser.swift
//  weatherApp
//
//  Created by Narmin Baghirova on 22.06.26.
//

import Foundation

struct MessagerUser: Identifiable, Codable, Hashable {
    var uid: String
    var email: String

    var id: String {
        uid
    }
}
