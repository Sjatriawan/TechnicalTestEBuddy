//
//  UserView.swift
//  TechnicalTestEbuddy
//
//  Created by M Yogi Satriawan on 27/12/24.
//
import SwiftUI
import SwiftUI

struct UserView: View {
    @StateObject private var viewModel = UserViewModel()
    @State private var userId = "B4E7E20C-FCB3-40CC-90CF-FEA3C6677F65" //Sample UID from Firestore
    
    var body: some View {
        NavigationView {
            List {
                if let user = viewModel.user {
                    Section(header: Text("Information")) {
                        profileRow(title: "User ID", value: user.id)
                        profileRow(title: "Email", value: user.email ?? "Not Provided")
                        profileRow(title: "Phone", value: user.phoneNumber ?? "Not Provided")
                        profileRow(title: "Gender", value: user.ge?.displayName ?? "Not Specified")
                    }
                } else if let errorMessage = viewModel.errorMessage {
                    Section {
                        errorRow(message: errorMessage)
                    }
                } else {
                    Section {
                        HStack {
                            Spacer()
                            ProgressView("Loading...")
                                .background(.clear)
                                .progressViewStyle(CircularProgressViewStyle())
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Profile")
            .task {
                await viewModel.fetchUser(by: userId)
            }
            .refreshable {
                await viewModel.fetchUser(by: userId)
            }
        }
    }
    
    private func profileRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .foregroundColor(.primary)
                .multilineTextAlignment(.trailing)
                .lineLimit(1)
        }
    }
    
    private func errorRow(message: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.red)
            Text(message)
                .foregroundColor(.red)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
