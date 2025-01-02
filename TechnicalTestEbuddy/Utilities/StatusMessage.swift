//
//  StatusMessage.swift
//  TechnicalTestEbuddy
//
//  Created by M Yogi Satriawan on 28/12/24.
//

import Foundation
import SwiftUI

struct StatusMessage: View {
    let message: String
    let type: StatusType
    
    enum StatusType {
        case success
        case error
        
        var color: Color {
            switch self {
            case .success: return .green
            case .error: return .red
            }
        }
        
        var icon: String {
            switch self {
            case .success: return "checkmark.circle.fill"
            case .error: return "exclamationmark.circle.fill"
            }
        }
    }
    
    var body: some View {
        HStack {
            Image(systemName: type.icon)
            Text(message)
            Spacer()
        }
        .padding()
        .foregroundColor(type.color)
        .background(type.color.opacity(0.1))
        .cornerRadius(8)
    }
}
