//
//  GetHeightModifier.swift
//  weatherApp
//
//  Created by Narmin Baghirova on 18.06.26.
//

import SwiftUI

struct GetHeightModifier: ViewModifier {
    @Binding var height: CGFloat

    func body(content: Content) -> some View {
        content.background(
            GeometryReader { geo -> Color in
                DispatchQueue.main.async {
                    withAnimation(.easeInOut) {
                        height = geo.size.height
                    }
                }
                return Color.clear
            }
        )
    }
}
