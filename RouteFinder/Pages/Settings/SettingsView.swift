//
//  SettingsView.swift
//  RouteFinder
//
//  Created by Connor Stevens on 11/19/24.
//

import Foundation
import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = AuthSessionViewModel()

    var body: some View {
        NavigationStack {
            VStack {
                if viewModel.isLoading {
                    ProgressView("Loading...")
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding()
                } else if let session = viewModel.authSession {
                    VStack(spacing: 16) {
                        if let profilePictureUrl = session.profilePictureUrl, let url = URL(string: profilePictureUrl) {
                            AsyncImage(url: url) { image in
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 100, height: 100)
                                    .clipShape(Circle())
                            } placeholder: {
                                Circle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 100, height: 100)
                            }
                        }

                        Text(session.firstName ?? "Aviator")
                            .font(.title2)
                            .bold()

                        Text(session.emailAddress)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()

                    List {
                        Section(header: Text("General")) {
                            NavigationLink(destination: AccountSettingsView(profile: viewModel.authSession!)) {
                                Label("Account", systemImage: "person.crop.circle")
                            }
                        }

                        Section(header: Text("Preferences")) {
                            NavigationLink(destination: AppearanceSettingsView()) {
                                Label("Appearance", systemImage: "paintbrush")
                            }
                        }

                        Section {
                            Button(action: {
                                AuthenticationManager.shared.clearToken()
                            }) {
                                Label("Log Out", systemImage: "arrow.backward.square")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                } else if let error = viewModel.errorMessage {
                    Text("Error: \(error)")
                        .foregroundColor(.red)
                        .padding()
                }

                Spacer()
            }
            .navigationTitle("Settings")
        }
        .onAppear {
            viewModel.loadAuthSession()
        }
    }
}
