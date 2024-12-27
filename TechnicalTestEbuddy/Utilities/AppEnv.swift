//
//  AppEnv.swift
//  TechnicalTestEbuddy
//
//  Created by M Yogi Satriawan on 27/12/24.
//

import SwiftUI
import FirebaseCore

enum AppEnv {
    case development
    case staging
    case production

    var firebasePlistFileName: String {
        switch self {
        case .development:
            return "GoogleService-Info-Development"
        case .staging:
            return "GoogleService-Info-Staging"
        case .production:
            return "GoogleService-Info-Production"
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    let currentEnvironment: AppEnv = {
        #if DEVELOPMENT
        return .development
        #elseif STAGING
        return .staging
        #else
        return .production
        #endif
    }()
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        configureFirebase(for: currentEnvironment)
        return true
    }

    private func configureFirebase(for environment: AppEnv) {
        guard let filePath = Bundle.main.path(forResource: environment.firebasePlistFileName, ofType: "plist") else {
            fatalError("Missing Firebase configuration file for \(environment)")
        }

        let options = FirebaseOptions(contentsOfFile: filePath)
        FirebaseApp.configure(options: options!)
    }
}

