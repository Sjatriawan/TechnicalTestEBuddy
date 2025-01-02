//
//  GameIcon.swift
//  TechnicalTestEbuddy
//
//  Created by M Yogi Satriawan on 28/12/24.
//

import Foundation
import SwiftUI


struct GameIcon: Identifiable, Decodable {
    var id = UUID()
    let gameName: String
    
    var icon: String {
        let processedName = gameName.lowercased().replacingOccurrences(of: " ", with: "_")
        print("Generated icon name: \(processedName)")
        if UIImage(named: processedName) != nil {
            print("✅ Found image for: \(processedName)")
        } else {
            print("❌ No image found for: \(processedName)")
        }
        return processedName
    }
}
