//
//  ActionButton.swift
//  weatherApp
//
//  Created by Narmin Baghirova on 29.06.26.
//

import SwiftUI

struct ActionButton: View {
    let iconName: String
    let completion: () -> Void
    
    var body: some View {
        Button {
            completion()
        } label: {
            Image(systemName: iconName)
                .padding()
                .background(Color.white)
                .clipShape(Circle())
                .shadow(radius: 4)
        }
    }
}
