//
//  AirportView.swift
//  RouteFinder
//
//  Created by Connor Stevens on 11/19/24.
//

import SwiftUI

struct AirportView: View {
    @StateObject private var airportViewModel = AirportViewModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                PaginationView(viewModel: airportViewModel) { airport in
                    NavigationLink(destination: AirportDetailView(airport: airport)) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("\(airport.name)")
                                    .font(.headline)
                                Text("IATA Code: \(airport.iataCode)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
                .navigationTitle("Airports")
            }.onAppear {
                airportViewModel.loadItems()
            }
        }
    }
    
    private class AirportViewModel: PaginatedViewModel {
        var items: [Airport] = []
        
        typealias Item = Airport
        
        @Published var errorMessage: String?
        @Published var isLoading: Bool = false
        
        @Published var page: Int = 1
        @Published var limit: Int = 10
        @Published var hasMore: Bool = false
        @Published var totalCount: Int = 0
        
        private let airportService = AirportService()
        
        var canGoBack: Bool {
            page > 1
        }
        
        var canGoForward: Bool {
            self.hasMore
        }
        
        func loadItems() {
            isLoading = true
            
            airportService.listAirports(page: page, limit: limit) { [weak self] result in
                DispatchQueue.main.async {
                    self?.isLoading = false
                    
                    switch result {
                    case .success(let airports):
                        self?.items = airports.data
                        self?.page = airports.pagination.page
                        self?.hasMore = airports.pagination.hasMore
                        self?.totalCount = airports.pagination.totalCount
                        
                    case .failure(let _error) :
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
