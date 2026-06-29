//
//  Models.swift
//  weatherApp
//
//  Created by Narmin Baghirova on 17.06.26.
//

import Foundation

// MARK: - Forecast
public struct Forecast: Codable {
    let latitude, longitude, generationtimeMS: Double
    let utcOffsetSeconds: Int
    let timezone, timezoneAbbreviation: String
    let elevation: Int
    let currentUnits: CurrentUnits
    let current: Current
    
    public var currentTemperature: Double? {
        current.temperature2M
    }
    
    public var currentWeatherCode: Int? {
        current.weatherCode
    }
    
    enum CodingKeys: String, CodingKey {
        case latitude, longitude
        case generationtimeMS = "generationtime_ms"
        case utcOffsetSeconds = "utc_offset_seconds"
        case timezone
        case timezoneAbbreviation = "timezone_abbreviation"
        case elevation
        case currentUnits = "current_units"
        case current
    }
}

// MARK: - Current
public struct Current: Codable {
    let time: String
    let interval: Int
    let temperature2M: Double
    let relativeHumidity2M, weatherCode: Int
    let windSpeed10M: Double
    let precipitation: Int

    enum CodingKeys: String, CodingKey {
        case time, interval
        case temperature2M = "temperature_2m"
        case relativeHumidity2M = "relative_humidity_2m"
        case weatherCode = "weather_code"
        case windSpeed10M = "wind_speed_10m"
        case precipitation
    }
}

// MARK: - CurrentUnits
public struct CurrentUnits: Codable {
    let time, interval, temperature2M, relativeHumidity2M: String
    let weatherCode, windSpeed10M, precipitation: String

    enum CodingKeys: String, CodingKey {
        case time, interval
        case temperature2M = "temperature_2m"
        case relativeHumidity2M = "relative_humidity_2m"
        case weatherCode = "weather_code"
        case windSpeed10M = "wind_speed_10m"
        case precipitation
    }
}

// MARK: - Hourly
public struct Hourly: Codable {
    let time: [String]
    let temperature2M: [Double]
    let weatherCode: [Int]

    enum CodingKeys: String, CodingKey {
        case time
        case temperature2M = "temperature_2m"
        case weatherCode = "weather_code"
    }
}

// MARK: - HourlyUnits
public struct HourlyUnits: Codable {
    let time, temperature2M, weatherCode: String

    enum CodingKeys: String, CodingKey {
        case time
        case temperature2M = "temperature_2m"
        case weatherCode = "weather_code"
    }
}

public struct Message: Identifiable, Sendable {
    public let id: String
    public let text: String
    public let senderID: String
    public let senderMail: String
    public let timestamp: Date

    public init(
        id: String,
        text: String,
        senderID: String,
        senderMail: String,
        timestamp: Date
    ) {
        self.id = id
        self.text = text
        self.senderID = senderID
        self.senderMail = senderMail
        self.timestamp = timestamp
    }
}

public struct MessagerUser: Codable, Hashable, Sendable {
    public let uid: String
    public let email: String

    public init(uid: String, email: String) {
        self.uid = uid
        self.email = email
    }
}

public struct RecieverUser: Hashable, Sendable {
    public let userID: String
    public let userEmail: String

    public init(userID: String, userEmail: String) {
        self.userID = userID
        self.userEmail = userEmail
    }
}
