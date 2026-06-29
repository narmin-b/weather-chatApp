//
//  NavigationTypes.swift
//  weatherApp
//
//  Created by Narmin Baghirova on 25.06.26.
//

import Foundation
import AppServices

enum AppPage: Hashable {
    case main
    case usersList
    case chat(user: RecieverUser)
}
