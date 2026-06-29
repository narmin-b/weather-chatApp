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
            progressView
        } else if !(errorMessage ?? "").isEmpty {
            errorMessageField
        } else {
            VStack(spacing: 8) {
                locationField
                    .padding(.top, 20)
                
                weatherDescriptionField
                tempField
            }
            .multilineTextAlignment(.center)
        }
    }
    
    var progressView: some View {
        VStack {
            Spacer()
            ProgressView()
                .scaleEffect(4)
                .frame(minHeight: 120)
            Spacer()
        }
    }
    
    var errorMessageField: some View {
        Text("\(errorMessage ?? "")")
            .font(.system(size: 24))
            .multilineTextAlignment(.center)
            .frame(minHeight: 120)
    }
    
    var locationField: some View {
        HStack {
            Image(systemName: "location.fill")
                .font(.system(size: 16))
            Text("\(loc ?? "")")
                .font(.system(size: 16))
                .multilineTextAlignment(.center)
        }
    }
    
    var weatherDescriptionField: some View {
        HStack {
            Text("\(weatherDescription?.description ?? "")")
                .font(.system(size: 24))
                .multilineTextAlignment(.leading)
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.iconBg)
                    .frame(width: 40, height: 40)
                Image(systemName: weatherDescription?.iconName ?? "")
                    .font(.system(size: 24))
                    .foregroundColor(weatherDescription?.iconColor)
            }
        }
    }
    
    var tempField: some View {
        Text("\(temp ?? 0, specifier: "%.f")")
            .font(.system(size: 64, weight: .heavy))
            .foregroundStyle(Color.blue)
        +
        Text("°C")
            .font(.system(size: 24, weight: .semibold))
            .foregroundStyle(Color.blue)
    }
}
