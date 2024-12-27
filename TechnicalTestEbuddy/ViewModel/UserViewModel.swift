//
//  UserViewModel.swift
//  TechnicalTestEbuddy
//
//  Created by M Yogi Satriawan on 27/12/24.
//

import FirebaseFirestore
import Foundation

class UserViewModel: ObservableObject {
    @Published var user: UserJSON?
    @Published var errorMessage: String?
    @Published var successMessage: String?

    private let db = Firestore.firestore()

    func fetchUser(by uid: String) async {
        do {
            let document = try await db.collection("USERS").document(uid).getDocument(source: .server)

            if document.exists {
                if let decodedUser = try? document.data(as: UserJSON.self) {
                    DispatchQueue.main.async {
                        self.user = decodedUser
                        self.errorMessage = nil
                    }
                } else {
                    DispatchQueue.main.async {
                        self.errorMessage = "Failed to decode user data."
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.errorMessage = "User not found."
                }
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Error fetching user: \(error.localizedDescription)"
            }
        }
    }
}
