//
//  ProfileService.swift
//  TechnicalTestEbuddy
//
//  Created by M Yogi Satriawan on 28/12/24.
//

import Foundation
import SwiftUI


class ProfileService {
    static func loadProfiles() -> [CardViewModel] {
        guard let url = Bundle.main.url(forResource: "profiles", withExtension: "json") else {
            fatalError("Failed to locate profiles.json in bundle.")
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decodedProfiles = try JSONDecoder().decode([CardViewModel].self, from: data)
            return decodedProfiles
        } catch {
            fatalError("Failed to decode JSON: \(error)")
        }
    }
}

