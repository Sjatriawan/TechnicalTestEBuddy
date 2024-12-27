//
//  User.swift
//  TechnicalTestEbuddy
//
//  Created by M Yogi Satriawan on 27/12/24.
//

import Foundation


@frozen
public enum Gender: Int, Codable, CaseIterable {
    case female = 0
    case male = 1
    
    public var displayName: String {
        switch self {
        case .female: return "Female"
        case .male: return "Male"
        }
    }
}

public struct UserJSON: Codable, Identifiable, Hashable {
    public let id: String
    public var email: String?
    public var phoneNumber: String?
    public var ge: Gender?
    
    private enum CodingKeys: String, CodingKey {
        case id = "uid"
        case email
        case phoneNumber
        case ge
    }
    
    public init(
        id: String,
        email: String? = nil,
        phoneNumber: String? = nil,
        ge: Gender? = nil
    ) {
        self.id = id
        self.email = email
        self.phoneNumber = phoneNumber
        self.ge = ge
    }
    
 
    public func validate() throws {
        if let email = email {
            guard email.contains("@") else {
                throw ValidationError.invalidEmail
            }
        }
        
        if let phoneNumber = phoneNumber {
            guard phoneNumber.starts(with: "+"), phoneNumber.count >= 8 else {
                throw ValidationError.invalidPhoneNumber
            }
        }
    }
}


public enum ValidationError: LocalizedError {
    case invalidEmail
    case invalidPhoneNumber
    
    public var errorDescription: String? {
        switch self {
        case .invalidEmail:
            return "Invalid email format"
        case .invalidPhoneNumber:
            return "Invalid phone number format. Must be in E.164 format (e.g., +1234567890)"
        }
    }
}


extension UserJSON {
    public static func anonymous() -> UserJSON {
        UserJSON(id: UUID().uuidString)
    }
    
    public var hasCompletedProfile: Bool {
        email != nil && ge != nil
    }
}

