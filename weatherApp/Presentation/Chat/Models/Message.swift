//
//  Message.swift
//  weatherApp
//
//  Created by Narmin Baghirova on 18.06.26.
//

import Foundation

struct Message: Identifiable {
    let id: String
    let text: String
    let senderID: String
    let senderMail: String
    let timestamp: Date
}
