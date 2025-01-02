//
//  UserView.swift
//  TechnicalTestEbuddy
//
//  Created by M Yogi Satriawan on 27/12/24.
//

import SwiftUI

// Enum for filter options
enum FilterOption: String, CaseIterable {
    case none = "No Filter"
    case recentlyActive = "Recently Active"
    case highestRating = "Highest Rating"
    case lowestPricing = "Lowest Pricing"
    case femaleOnly = "Female Only"
}

// Constants for UI layout
private enum Constants {
    static let iconSize: CGFloat = 40
    static let spacing: CGFloat = -15
}

struct UserView: View {
    @StateObject private var viewModel = UserViewModel() // ViewModel to handle data
    @State private var selectedUser: UserJSON? // Selected user for detail view
    @State private var isFiltering = false // Toggle for filtering
    @State private var selectedFilter: FilterOption = .none // Currently selected filter option
    
    // Layout configuration for grid
    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.primary) // Background color
                    .ignoresSafeArea()
                
                // Handle different states of the view
                if viewModel.isLoading {
                    loadingView
                } else if viewModel.allUsers.isEmpty {
                    emptyStateView
                } else {
                    mainContentView
                }
            }
            .navigationTitle(getNavigationTitle())
            .task {
                await viewModel.fetchAllUsers() // Fetch data on view load
            }
            .sheet(item: $selectedUser) { user in
                //UserDetailView(user: user)
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") {
                    viewModel.errorMessage = nil
                }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        // Filter options menu
                        ForEach(FilterOption.allCases, id: \.self) { filter in
                            Button {
                                applyFilter(filter)
                            } label: {
                                Label(filter.rawValue, systemImage: selectedFilter == filter ? "checkmark" : "")
                            }
                        }
                    } label: {
                        Label("Filter", systemImage: "line.horizontal.3.decrease.circle")
                    }
                }
            }
        }
    }
    
    // Apply selected filter to the data
    private func applyFilter(_ filter: FilterOption) {
        selectedFilter = filter
        viewModel.resetPagination() // Reset pagination when filter is applied
        
        Task {
            do {
                switch filter {
                case .none:
                    await viewModel.fetchAllUsers()
                case .recentlyActive:
                    _ = try await viewModel.fetchFilteredUsers(
                        orderBy: "lastActiveTimestamp",
                        descending: true,
                        resetPagination: true
                    )
                case .highestRating:
                    _ = try await viewModel.fetchFilteredUsers(
                        orderBy: "rating",
                        descending: true, // Highest first
                        resetPagination: true
                    )
                case .lowestPricing:
                    _ = try await viewModel.fetchFilteredUsers(
                        orderBy: "hourlyRate",
                        descending: false,
                        resetPagination: true
                    )
                case .femaleOnly:
                    _ = try await viewModel.fetchFilteredUsers(
                        filterGender: "female",
                        resetPagination: true
                    )
                }
            } catch {
                print("Error applying filter: \(error)")
                viewModel.errorMessage = error.localizedDescription
            }
        }
    }
    
 
    
    // Main content view that shows the list of users
    private var mainContentView: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(sortedUsers(), id: \.key) { (userId, userData) in
                    userCard(userId: userId, userData: userData)
                }
            }
            .padding(.horizontal, 16)
        }
        .scrollIndicators(.hidden)
        .refreshable {
            await refreshData() // Pull-to-refresh functionality
        }
    }

    // Sorting users based on selected filter
    private func sortedUsers() -> [(key: String, value: [String: Any])] {
        let users = viewModel.allUsers
        
        switch selectedFilter {
        case .lowestPricing:
            return users.sorted {
                let rate1 = ($0.value["hourlyRate"] as? NSNumber)?.doubleValue ?? 0.0
                let rate2 = ($1.value["hourlyRate"] as? NSNumber)?.doubleValue ?? 0.0
                return rate1 < rate2
            }
        case .highestRating:
            return users.sorted {
                let rating1 = ($0.value["rating"] as? NSNumber)?.doubleValue ?? 0.0
                let rating2 = ($1.value["rating"] as? NSNumber)?.doubleValue ?? 0.0
                return rating1 > rating2
            }
        case .recentlyActive:
            return users.sorted {
                let timestamp1 = ($0.value["lastActiveTimestamp"] as? NSNumber)?.doubleValue ?? 0.0
                let timestamp2 = ($1.value["lastActiveTimestamp"] as? NSNumber)?.doubleValue ?? 0.0
                return timestamp1 > timestamp2
            }
        default:
            return Array(users)
        }
    }
    
    // Create a user card view for each user
    private func userCard(userId: String, userData: [String: Any]) -> some View {
        let gameIcons: [GameIcon] = (userData["games"] as? [String] ?? [])
            .map { GameIcon(gameName: $0) }
        
        return Button {
            Task {
                do {
                    try await viewModel.fetchUser(by: userId)
                    selectedUser = viewModel.user
                } catch {
                    print("Failed to fetch user: \(error)")
                }
            }
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                ProfileCard(
                    username: userData["username"] as? String ?? "Unknown User",
                    rating: userData["rating"] as? Double ?? 0.0,
                    ratingCount: userData["ratingCount"] as? Int ?? 0,
                    hourlyRate: userData["hourlyRate"] as? Double ?? 0.0,
                    isOnline: userData["isOnline"] as? Bool ?? false,
                    isVerified: userData["isVerified"] as? Bool ?? false,
                    games: [GameIcon(gameName: "call_of_duty"),
                            GameIcon(gameName: "mobile_legends"),
                            GameIcon(gameName: "valorant")]
                )
                .frame(maxWidth: .infinity)
            }
        }
        .buttonStyle(ScaleButtonStyle()) // Custom button scale animation
    }

    // Loading view shown when data is loading
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(.blue)
            Text("Loading users...")
                .font(.callout)
                .foregroundColor(.secondary)
        }
    }
    
    // Empty state view when no users are found
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.2.slash")
                .font(.system(size: 50))
                .foregroundColor(.secondary)
            Text("No users found")
                .font(.headline)
            Text("Pull to refresh")
                .font(.callout)
                .foregroundColor(.secondary)
        }
    }
    
    // Toggle filter function
    private func toggleFilter() {
        isFiltering.toggle()
        Task {
            if isFiltering {
                _ = try? await viewModel.fetchFilteredUsers() // Apply filter
            } else {
                await viewModel.fetchAllUsers() // Show all data
            }
        }
    }
    
    // Refresh the user data based on the filter state
    private func refreshData() async {
        do {
            if isFiltering {
                _ = try await viewModel.fetchFilteredUsers()
            } else {
                await viewModel.fetchAllUsers()
            }
        } catch {
            await viewModel.fetchAllUsers() // Fallback to fetching all users on error
        }
    }
    
    // Get navigation title based on selected filter
    private func getNavigationTitle() -> String {
        switch selectedFilter {
        case .none:
            return "All Users"
        case .recentlyActive:
            return "Recently Active Users"
        case .highestRating:
            return "Highest Rated Users"
        case .lowestPricing:
            return "Lowest Pricing Users"
        case .femaleOnly:
            return "Female Users"
        }
    }
}

// Custom button style with scale animation
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}
