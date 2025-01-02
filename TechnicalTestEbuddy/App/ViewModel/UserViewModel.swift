//
//  UserViewModel.swift
//  TechnicalTestEbuddy
//
//  Created by M Yogi Satriawan on 27/12/24.
//

import FirebaseFirestore
import FirebaseStorage
import Foundation
import UIKit
import Network
import FirebaseAuth

enum UserViewModelError: Error {
    case documentNotFound
    case failedToDecodeUserData
    case failedToFetchUserData
    case failedToUploadImage
    case failedToUpdateUserProfile
    case failedToStoreUserData
    case failedToFilterUsers
    case networkError
    case invalidData
    
    var localizedDescription: String {
        switch self {
        case .documentNotFound:
            return "User not found."
        case .failedToDecodeUserData:
            return "Failed to decode user data."
        case .failedToFetchUserData:
            return "Error fetching user data."
        case .failedToUploadImage:
            return "Failed to upload image."
        case .failedToUpdateUserProfile:
            return "Failed to update user profile."
        case .failedToStoreUserData:
            return "Failed to store user data."
        case .failedToFilterUsers:
            return "Failed to filter users based on criteria."
        case .networkError:
            return "Network connection issue. Please check your internet connection."
        case .invalidData:
            return "Invalid data received from the server."
        }
    }
}

@MainActor
class UserViewModel: ObservableObject {
    @Published private(set) var user: UserJSON?
    @Published private(set) var allUsers: [String: [String: Any]] = [:]
    @Published var errorMessage: String?
    @Published private(set) var successMessage: String?
    @Published var selectedImage: UIImage?
    @Published var isImagePickerPresented = false
    @Published private(set) var isLoading = false
    @Published private(set) var networkStatus: NetworkStatus = .unknown
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    private let db = Firestore.firestore()
    private var lastDocument: DocumentSnapshot?
    
    enum NetworkStatus {
        case connected
        case disconnected
        case unknown
    }
    
    init() {
        setupNetworkMonitoring()
    }
    
    

        func  fetchCurrentUserProfileSample() async {
            guard networkStatus == .connected else {
                errorMessage = UserViewModelError.networkError.localizedDescription
                return
            }
            
            isLoading = true
            defer { isLoading = false }
            
            // Ganti dengan UID statis Anda
            let staticUID = "0e1a4381-99b7-44d2-a1be-67a8e9819c27"

            
            do {
                let document = try await db.collection("USERS").document(staticUID).getDocument()
                
                if let data = document.data() {
                    self.allUsers = [document.documentID: data] // Simpan data ke allUsers
                    self.errorMessage = nil
                } else {
                    self.errorMessage = "User with UID \(staticUID) not found."
                }
                
            } catch {
                self.errorMessage = "Failed to fetch user by static UID: \(error.localizedDescription)"
            }
        }
 
    func fetchCurrentUserProfile() async {
           guard let uid = Auth.auth().currentUser?.uid else {
               errorMessage = "User not authenticated"
               return
           }

           do {
               let document = try await db.collection("USERS").document(uid).getDocument()
               if document.exists {
                   let decodedUser = try document.data(as: UserJSON.self)
                   self.user = decodedUser
                   self.errorMessage = nil
               } else {
                   self.errorMessage = UserViewModelError.documentNotFound.localizedDescription
               }
           } catch {
               self.errorMessage = "Failed to fetch user profile: \(error.localizedDescription)"
           }
       }
    
    private func setupNetworkMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            Task { @MainActor in
                guard let self = self else { return }
                
                let previousStatus = self.networkStatus
                switch path.status {
                case .satisfied:
                    self.networkStatus = .connected
                    if previousStatus == .disconnected {
                        await self.retryFetchingUsers()
                    }
                case .unsatisfied:
                    self.networkStatus = .disconnected
                default:
                    self.networkStatus = .unknown
                }
            }
        }
        monitor.start(queue: queue)
    }
    
    
    
    private func retryFetchingUsers() async {
        do {
            let users = try await fetchFilteredUsers(orderBy: "name", descending: false, filterGender: nil, limit: 10, resetPagination: true)
            print("Fetched users after reconnection: \(users)")
        } catch {
            errorMessage = "Error fetching users: \(error.localizedDescription)"
        }
    }
    
    // MARK: - User Fetching Methods
    func fetchAllUsers() async {
        guard networkStatus == .connected else {
            errorMessage = UserViewModelError.networkError.localizedDescription
            return
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            let snapshot = try await db.collection("USERS").getDocuments()
            
            var usersData: [String: [String: Any]] = [:]
            for document in snapshot.documents {
                usersData[document.documentID] = document.data()
            }
            
            self.allUsers = usersData
            self.errorMessage = usersData.isEmpty ? "No users found." : nil
            
        } catch {
            self.errorMessage = "Failed to fetch all users: \(error.localizedDescription)"
        }
    }
    
    func fetchUser(by uid: String) async throws {
        guard networkStatus == .connected else {
            throw UserViewModelError.networkError
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            let document = try await db.collection("USERS").document(uid).getDocument(source: .server)
            guard document.exists else {
                throw UserViewModelError.documentNotFound
            }
            
            let decodedUser = try document.data(as: UserJSON.self)
            self.user = decodedUser
            self.errorMessage = nil
            
        } catch {
            throw UserViewModelError.failedToFetchUserData
        }
    }
    
    
    func fetchFilteredUsers(
        orderBy field: String? = nil,
        descending: Bool = true,
        filterGender: String? = nil,
        limit: Int = 20,
        resetPagination: Bool = false
    ) async throws -> [String: [String: Any]] {
        guard networkStatus == .connected else {
            throw UserViewModelError.networkError
        }
        
        isLoading = true
        defer { isLoading = false }
        
        if resetPagination {
            lastDocument = nil
        }
        
        var query: Query = db.collection("USERS")
        
        if let filterGender = filterGender {
            query = query.whereField("ge", isEqualTo: filterGender)
        }
        
        if let field = field {
            switch field {
            case "isOnline":
                query = query.whereField("isOnline", isEqualTo: true)
                query = query.order(by: "lastActiveTimestamp", descending: descending)
                
            case "rating":
                query = query.order(by: "rating", descending: descending)
                
            case "hourlyRate":
                query = query.order(by: "hourlyRate", descending: descending)
                
            case "lastActiveTimestamp":
                query = query.order(by: "lastActiveTimestamp", descending: descending)
                
            default:
                query = query.order(by: field, descending: descending)
            }
        }
        
        if let lastDocument = lastDocument {
            query = query.start(afterDocument: lastDocument)
        }
        
        query = query.limit(to: limit)
        
        do {
            let snapshot = try await query.getDocuments()
            
            if snapshot.documents.isEmpty {
                return [:]
            }
            
            lastDocument = snapshot.documents.last
            
            var filteredUsersData: [String: [String: Any]] = [:]
            for document in snapshot.documents {
                let data = document.data()
                filteredUsersData[document.documentID] = data
                
                if let hourlyRate = data["hourlyRate"] {
                    print("Raw hourlyRate for \(document.documentID): \(hourlyRate), type: \(type(of: hourlyRate))")
                }
            }
            
            if resetPagination {
                allUsers = filteredUsersData
            } else {
                allUsers.merge(filteredUsersData) { current, _ in current }
            }
            
            return filteredUsersData
            
        } catch let error {
            print("Firebase error: \(error.localizedDescription)")
            throw UserViewModelError.failedToFilterUsers
        }
    }
    
    func uploadImage(_ image: UIImage?, forUser user: UserJSON) async throws {
        guard networkStatus == .connected else {
            throw UserViewModelError.networkError
        }
        
        guard let image = image,
              let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw UserViewModelError.failedToUploadImage
        }
        
        isLoading = true
        defer { isLoading = false }
        
        let storageRef = Storage.storage().reference()
        let imageRef = storageRef.child("images_user/\(user.id)/profile_image.jpg")
        
        do {
            _ = try await imageRef.putDataAsync(imageData)
            let url = try await imageRef.downloadURL()
            try await saveImageURL(url.absoluteString, forUser: user)
            successMessage = "Profile image updated successfully!"
        } catch {
            throw UserViewModelError.failedToUploadImage
        }
    }
    
    private func saveImageURL(_ imageURL: String, forUser user: UserJSON) async throws {
        let userRef = db.collection("USERS").document(user.id)
        
        do {
            try await userRef.updateData(["profileImageURL": imageURL])
        } catch {
            throw UserViewModelError.failedToUpdateUserProfile
        }
    }
    
    func clearError() {
        errorMessage = nil
    }
    
    func clearSuccess() {
        successMessage = nil
    }
    
    deinit {
        monitor.cancel()
    }
}

extension UserViewModel {
    func resetPagination() {
        lastDocument = nil
    }
}
