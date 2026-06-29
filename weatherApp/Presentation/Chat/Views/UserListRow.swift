//
//  UserListRow.swift
//  weatherApp
//
//  Created by Narmin Baghirova on 29.06.26.
//

import SwiftUI

struct UserListRow: View {
    let userEmail: String
    let completion: () -> Void
    
    var body: some View {
        Button {
            completion()
        } label: {
            Text(userEmail)
        }
    }
}

