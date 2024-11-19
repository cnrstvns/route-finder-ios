//
//  Home.swift
//  RouteFinder
//
//  Created by Connor Stevens on 11/18/24.
//

import Foundation
import SwiftUI

struct Home: View {
    var body: some View {
        NavigationStack {
            Text("Welcome to RouteFinder")
                .foregroundStyle(.gray)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading)
            
            List {
                Section(header: Text("Resources")) {
                    NavigationLink(destination: AircraftView()) {
                        HStack(spacing: 16) {
                            Image(systemName: "airplane")
                            VStack(alignment: .leading) {
                                Text("Aircraft")
                                    .font(.headline)
                                Text("Explore different aircraft models")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    NavigationLink(destination: AirlineView()) {
                        HStack(spacing: 16) {
                            Image(systemName: "person.fill")
                            VStack(alignment: .leading) {
                                Text("Airlines")
                                    .font(.headline)
                                Text("Browse top carriers")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    NavigationLink(destination: AirportView()) {
                        HStack(spacing: 16) {
                            Image(systemName: "airplane.arrival")
                            VStack(alignment: .leading) {
                                Text("Airports")
                                    .font(.headline)
                                Text("Explore 1,000+ airports")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    NavigationLink(destination: FavoritesView()) {
                        HStack(spacing: 16) {
                            Image(systemName: "bookmark.fill")
                            VStack(alignment: .leading) {
                                Text("Saved Routes")
                                    .font(.headline)
                                Text("Easily access your favorite routes")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Home")
            .listStyle(InsetGroupedListStyle())
        }
    }
}

#Preview {
    Home()
}
