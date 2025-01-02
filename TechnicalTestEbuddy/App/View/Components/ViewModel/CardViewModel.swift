//
//  CardViewModel.swift
//  TechnicalTestEbuddy
//
//  Created by M Yogi Satriawan on 28/12/24.
//

import SwiftUI

struct CardViewModel: Identifiable, Decodable {
    let id: String
    let username: String
    let rating: Double
    let ratingCount: Int
    let hourlyRate: Double
    let isOnline: Bool
    let isVerified: Bool
    let games: [GameIcon]
    
    enum CodingKeys: String, CodingKey {
        case id
        case username
        case rating
        case ratingCount
        case hourlyRate
        case isOnline
        case isVerified
        case games
    }
    
    init(id: String? = nil, username: String, rating: Double, ratingCount: Int, hourlyRate: Double, isOnline: Bool, isVerified: Bool, games: [GameIcon]) {
        self.id = id ?? UUID().uuidString 
        self.username = username
        self.rating = rating
        self.ratingCount = ratingCount
        self.hourlyRate = hourlyRate
        self.isOnline = isOnline
        self.isVerified = isVerified
        self.games = games
    }
}
