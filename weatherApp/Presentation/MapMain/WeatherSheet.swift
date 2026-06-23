//
//  WeatherSheet.swift
//  weatherApp
//
//  Created by Narmin Baghirova on 18.06.26.
//

import SwiftUI

struct WeatherSheet: View {
    @Binding var isLoading: Bool
    @Binding var isPresented: Bool
    @Binding var temp: Double?
    @Binding var loc: String?
    @Binding var weatherDescription: WeatherDescription?
    @Binding var errorMessage: String?
    
    var body: some View {
        if isLoading {
            VStack {
                Spacer()
                ProgressView()
                    .scaleEffect(4)
                    .frame(minHeight: 120)
                Spacer()
            }
        } else if !(errorMessage ?? "").isEmpty {
            Text("\(errorMessage ?? "")")
                .font(.system(size: 24))
                .multilineTextAlignment(.center)
                .frame(minHeight: 120)
        } else {
            ZStack {
                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: "location.fill")
                            .font(.system(size: 16))
                        Text("\(loc ?? "")")
                            .font(.system(size: 16))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)
                    HStack {
                        Text("\(weatherDescription?.description ?? "")")
                            .font(.system(size: 24))
                            .multilineTextAlignment(.leading)
                        ZStack{
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.iconBg)
                                .frame(width: 40, height: 40)
                            Image(systemName: weatherDescription?.iconName ?? "")
                                .font(.system(size: 24))
                                .foregroundColor(weatherDescription?.iconColor)
                        }
                    }
                    Text("\(temp ?? 0, specifier: "%.f")")
                        .font(.system(size: 64, weight: .heavy))
                        .foregroundStyle(Color.blue)
                    +
                    Text("°C")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(Color.blue)
                }
            }
            .multilineTextAlignment(.center)
        }
    }
}

