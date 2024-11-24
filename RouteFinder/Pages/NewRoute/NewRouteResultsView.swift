//
//  NewRouteResultsView.swift
//  RouteFinder
//
//  Created by Connor Stevens on 11/22/24.
//

import SwiftUI

struct NewRouteResultsView: View {
    var airlineIata: String
    var minDuration: Double
    var maxDuration: Double
    var aircraftCodes: [String]
    
    @StateObject private var newRouteResultsViewModel = NewRouteResultsViewModel()
    
    var body: some View {
        NavigationStack {
            Text("\(newRouteResultsViewModel.totalCount) results found")
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading)
            
            VStack {
                PaginationView(viewModel: newRouteResultsViewModel) { searchRoute in
                    NavigationLink(destination: NewRouteDetailView(routeId: searchRoute.id)) {
                        HStack(alignment: .top, spacing: 12) {
                            VStack(alignment: .leading, spacing: 4) {
                                // Origin and Destination
                                Text("\(searchRoute.originIata) → \(searchRoute.destinationIata)")
                                    .font(.headline)
                                    .bold()
                                
                                // Airline Name (IATA code displayed here)
                                Text(searchRoute.airlineIata)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                // Duration
                                Text("Duration: \(formattedDuration(searchRoute.averageDuration))")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                // Matching Aircraft
                                HStack(spacing: 4) {
                                    if !searchRoute.matchingAircraftCodes.isEmpty {
                                        AircraftList(aircraftCodes: searchRoute.matchingAircraftCodes, highlight: true)
                                    }
                                    
                                    // Non-Matching Aircraft
                                    if !searchRoute.nonMatchingAircraftCodes.isEmpty {
                                        AircraftList(aircraftCodes: searchRoute.nonMatchingAircraftCodes, highlight: false)
                                    }
                                }
                            }
                            
                            Spacer()
                        }
                    }
                    .swipeActions(allowsFullSwipe: false) {
                        let isSaved = searchRoute.userRouteId != nil
                        
                        Button {
                            newRouteResultsViewModel.toggleSavedRoute(routeId: searchRoute.id)
                        } label: {
                            Label(isSaved ? "Unsave" : "Save", systemImage: isSaved ? "star.fill" : "star")
                        }
                        .tint(.indigo)
                    }
                }
                .navigationTitle("Results")
                .refreshable {
                    try? await Task.sleep(nanoseconds: 500 * 1_000_000) // Delay to prevent snapping
                    newRouteResultsViewModel.loadItems()
                }
            }
            .onAppear {
                newRouteResultsViewModel.airline = self.airlineIata
                newRouteResultsViewModel.aircraft = self.aircraftCodes
                newRouteResultsViewModel.minDuration = self.minDuration
                newRouteResultsViewModel.maxDuration = self.maxDuration
                newRouteResultsViewModel.loadItems()
            }
        }
    }
}

struct AircraftList: View {
    var aircraftCodes: [String]
    var highlight: Bool
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(aircraftCodes, id: \.self) { code in
                Button(action: {}) {
                    Text(code.trimmingCharacters(in: .whitespaces))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(highlight ? .blue.opacity(0.2) : .gray.opacity(0.2))
                        .foregroundColor(highlight ? .blue : .gray)
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
    
    if hours > 0 && remainingMinutes > 0 {
        return "\(hours) hour\(hours > 1 ? "s" : "") \(remainingMinutes) minute\(remainingMinutes > 1 ? "s" : "")"
    } else if hours > 0 {
        return "\(hours) hour\(hours > 1 ? "s" : "")"
    } else {
        return "\(remainingMinutes) minute\(remainingMinutes > 1 ? "s" : "")"
    }
}
private class NewRouteResultsViewModel: PaginatedViewModel {
    @Published var items: [SearchRoute] = []
    
    typealias Item = SearchRoute
    
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false
    
    @Published var page: Int = 1
    @Published var limit: Int = 10
    @Published var hasMore: Bool = false
    @Published var totalCount: Int = 0
    
    @Published var aircraft: [String] = []
    @Published var airline: String = ""
    @Published var minDuration: Double = 0.5
    @Published var maxDuration: Double = 20
    
    private let routeService = RouteService()
    private let userRouteService = UserRouteService()
    
    var canGoBack: Bool {
        page > 1
    }
    
    var canGoForward: Bool {
        self.hasMore
    }
    
    func loadItems() {
        isLoading = true
        
        routeService.searchRoutes(
            aircraft: self.aircraft.joined(separator: ","),
            airline: self.airline,
            minDuration: round(self.minDuration * 60), // convert to minutes,
            maxDuration: round(self.maxDuration * 60), // convert to minutes,
            page: page,
            limit: limit
        ) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let routes):
                    self?.items = routes.data
                    self?.page = routes.pagination.page
                    self?.hasMore = routes.pagination.hasMore
                    self?.totalCount = routes.pagination.totalCount
                    
                case .failure(_) :
                    self?.errorMessage = "Something went wrong"
                }
            }
        }
    }
    
    func loadItemsSilently() {
        routeService.searchRoutes(
            aircraft: self.aircraft.joined(separator: ","),
            airline: self.airline,
            minDuration: round(self.minDuration * 60), // convert to minutes,
            maxDuration: round(self.maxDuration * 60), // convert to minutes,
            page: page,
            limit: limit
        ) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let routes):
                    self?.items = routes.data
                    self?.page = routes.pagination.page
                    self?.hasMore = routes.pagination.hasMore
                    self?.totalCount = routes.pagination.totalCount
                    
                case .failure(_) :
                    self?.errorMessage = "Something went wrong"
                }
            }
        }
    }
    
    func toggleSavedRoute(routeId: Int) {
        userRouteService.toggleUserRoute(routeId: routeId) { [weak self] result in
            DispatchQueue.main.async {
                if let routeIndex = self?.items.firstIndex(where: { $0.id == routeId }) {
                    let route = self?.items[routeIndex]
                    
                    if route != nil {
                        self?.loadItemsSilently()
                    }
                }
                
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
