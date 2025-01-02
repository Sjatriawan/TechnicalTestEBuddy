//
//  User.swift
//  TechnicalTestEbuddy
//
//  Created by M Yogi Satriawan on 27/12/24.
//

import Foundation
import UIKit

@frozen
public enum Gender: Int, Codable, CaseIterable {
    case female = 0
    case male = 1
    
    /// Provides a user-friendly string representation of the gender.
    public var displayName: String {
        switch self {
        case .female: return "Female"
        case .male: return "Male"
        }
    }
}

public struct UserJSON: Codable, Identifiable, Hashable {
    // MARK: - Properties
    
    public let id: String
    public var username: String?
    public var email: String?
    public var phoneNumber: String?
    public var gender: Gender?
    public var profileImageURL: String?
    public var rating: Double
    public var hourlyRate: Double
    
    // Firebase key mappings
    private enum CodingKeys: String, CodingKey {
        case id = "uid"
        case username
        case email
        case phoneNumber
        case gender = "ge"  // Updated field name for gender in Firebase
        case profileImageURL
        case rating
        case hourlyRate
    }
    
    // MARK: - Initializer
    
    public init(
        id: String,
        username: String? = nil,
        email: String? = nil,
        phoneNumber: String? = nil,
        gender: Gender? = nil,
        profileImageURL: String? = nil,
        rating: Double = 0.0,
        hourlyRate: Double = 0.0
    ) {
        self.id = id
        self.username = username
        self.email = email
        self.phoneNumber = phoneNumber
        self.gender = gender
        self.profileImageURL = profileImageURL
        self.rating = rating
        self.hourlyRate = hourlyRate
    }
    
    // MARK: - Computed Properties
    
    /// Checks if the user's profile is complete.
    public var hasCompletedProfile: Bool {
        email != nil && phoneNumber != nil && gender != nil && username != nil
    }
    
    /// Provides a user-friendly summary of the user.
    public var summary: String {
        "\(username ?? "Anonymous") (\(gender?.displayName ?? "Not Specified"))"
    }
    
    /// Validates the user data for correctness.
    public func validate() throws {
        if let email = email, !isValidEmail(email) {
            throw ValidationError.invalidEmail
        }
        
        if let phoneNumber = phoneNumber, !isValidPhoneNumber(phoneNumber) {
            throw ValidationError.invalidPhoneNumber
        }
        
        if let profileImageURL = profileImageURL, !isValidURL(profileImageURL) {
            throw ValidationError.invalidProfileImageURL
        }
    }
    
    // MARK: - Helper Methods
    
    /// Validates email format.
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
    }
    
    /// Validates phone number format (E.164 format).
    private func isValidPhoneNumber(_ phoneNumber: String) -> Bool {
        return phoneNumber.starts(with: "+") && phoneNumber.count >= 8
    }
    
    /// Validates a URL format.
    private func isValidURL(_ urlString: String) -> Bool {
        guard let url = URL(string: urlString) else { return false }
        return UIApplication.shared.canOpenURL(url)
    }
}

// MARK: - Validation Errors

public enum ValidationError: LocalizedError {
    case invalidEmail
    case invalidPhoneNumber
    case invalidProfileImageURL
    
    public var errorDescription: String? {
        switch self {
        case .invalidEmail:
            return "Invalid email format"
        case .invalidPhoneNumber:
            return "Invalid phone number format. Must be in E.164 format (e.g., +1234567890)"
        case .invalidProfileImageURL:
            return "Invalid profile image URL format"
        }
    }
}

// MARK: - Extensions

extension UserJSON {
    /// Creates an anonymous user with a unique ID.
    public static func anonymous() -> UserJSON {
        UserJSON(id: UUID().uuidString)
    }
    
    /// Mock data for preview and testing purposes.
    public static var mockData: [UserJSON] {
        [
            UserJSON(
                id: UUID().uuidString,
                username: "JohnDoe",
                email: "john.doe@example.com",
                phoneNumber: "+1234567890",
                gender: .male,
                profileImageURL: nil,
                rating: 4.5,
                hourlyRate: 50.0
            ),
            UserJSON(
                id: UUID().uuidString,
                username: "Smith",
                email: nil,
                phoneNumber: "+9876543210",
                gender: .female,
                profileImageURL: "https://example.com/jane.jpg",
                rating: 4.8,
                hourlyRate: 60.0
            )
        ]
    }
}
