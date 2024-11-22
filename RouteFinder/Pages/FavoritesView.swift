//
//  FavoritesView.swift
//  RouteFinder
//
//  Created by Connor Stevens on 11/19/24.
//

import SwiftUI

struct FavoritesView: View {
    @StateObject private var userRouteViewModel = UserRouteViewModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                PaginationView(viewModel: userRouteViewModel) { userRoute in
                    NavigationLink(destination: FavoritesDetailView(userRouteId: userRoute.id)) {
                        HStack(alignment: .top, spacing: 12) {
                            VStack(alignment: .leading, spacing: 4) {
                                // Origin and Destination
                                Text("\(userRoute.origin.iataCode) → \(userRoute.destination.iataCode)")
                                    .font(.headline)
                                    .bold()
                                
                                // Airline Name
                                Text(userRoute.airline.name)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                // Duration
                                Text("Duration: \(formattedDuration(userRoute.route.averageDuration))")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                // Aircraft
                                if !userRoute.route.aircraftCodes.isEmpty {
                                    AircraftList(aircraftCodes: userRoute.route.aircraftCodes.split(separator: ",").map(String.init))
                                }
                            }
                            
                            Spacer()
                        }
                    }.swipeActions {
                        Button(role: .destructive) {
                            userRouteViewModel.deleteSavedRoute(routeId: userRoute.route.id)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
                .navigationTitle("Saved Routes")
                .refreshable {
                    try? await Task.sleep(nanoseconds: 500 * 1_000_000) // delay to prevent the view snapping
                    userRouteViewModel.loadItems()
                }
            }.onAppear {
                userRouteViewModel.loadItems()
            }
        }
    }
    
    struct AircraftList: View {
        var aircraftCodes: [String]
        
        var body: some View {
            HStack(spacing: 4) {
                ForEach(aircraftCodes, id: \.self) { code in
                    Button(action: {}) {
                        Text(code.trimmingCharacters(in: .whitespaces))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue.opacity(0.2))
                            .foregroundColor(.blue)
                            .cornerRadius(8)
                            .font(.system(size: 12, weight: .semibold))
                    }
                }
            }
        }
    }
    
    private func formattedDuration(_ minutes: Int) -> String {
        let hours = minutes / 60
        let remainingMinutes = minutes % 60
        return "\(hours) hour\(hours > 1 ? "s" : "") \(remainingMinutes) minute\(remainingMinutes > 1 ? "s" : "")"
    }
    
    private class UserRouteViewModel: PaginatedViewModel {
        var items: [ListUserRoute] = []
        
        typealias Item = ListUserRoute
        
        @Published var errorMessage: String?
        @Published var isLoading: Bool = false
        
        @Published var page: Int = 1
        @Published var limit: Int = 5
        @Published var hasMore: Bool = false
        @Published var totalCount: Int = 0
        
        private let userRouteService = UserRouteService()
        
        var canGoBack: Bool {
            page > 1
        }
        
        var canGoForward: Bool {
            self.hasMore
        }
        
        func loadItems() {
            isLoading = true
            
            userRouteService.listUserRoutes(page: page, limit: limit) { [weak self] result in
                DispatchQueue.main.async {
                    self?.isLoading = false
                    
                    switch result {
                    case .success(let userRoutes):
                        self?.items = userRoutes.data
                        self?.page = userRoutes.pagination.page
                        self?.hasMore = userRoutes.pagination.hasMore
                        self?.totalCount = userRoutes.pagination.totalCount
                        
                    case .failure(_):
                        self?.errorMessage = "Something went wrong"
                    }
                }
            }
        }
        
        func deleteSavedRoute(routeId: Int) {
            userRouteService.toggleUserRoute(routeId: routeId) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        break;

                    case .failure:
                        self?.errorMessage = "Something went wrong"
                    }
                    
                }
            }
        }
        
        func nextPage() {
            guard canGoForward else { return }
            page += 1
            loadItems()
        }
        
        func previousPage() {
            guard canGoBack else { return }
            page -= 1
            loadItems()
        }
    }
}
