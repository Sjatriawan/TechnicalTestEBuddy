//
//  TechnicalTestEbuddyApp.swift
//  TechnicalTestEbuddy
//
//  Created by M Yogi Satriawan on 27/12/24.
//

import SwiftUI
import FirebaseCore


@main
struct TechnicalTestEbuddyApp: App {
    let currentEnvironment: AppEnv = {
        #if DEVELOPMENT
        return .development
        #elseif STAGING
        return .staging
        #else
        return .production
        #endif
    }()

    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    print("Current Environment: \(currentEnvironment)")
                }
        }
    }
}
