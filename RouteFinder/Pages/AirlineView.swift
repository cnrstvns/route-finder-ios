//
//  AirlineView.swift
//  RouteFinder
//
//  Created by Connor Stevens on 11/19/24.
//

import Foundation
import SwiftUI

struct AirlineView: View {
    @StateObject private var airlineViewModel = AirlineViewModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                PaginationView(viewModel: airlineViewModel) { airline in
                        HStack(spacing: 12) {
                            VStack(alignment: .leading) {
                                if let url = URL(string: airline.logoPath) {
                                    AsyncImage(url: url) { image in
                                        image
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 50, height: 50)
                                            .clipShape(Circle())
                                    } placeholder: {
                                        ProgressView()
                                    }
                                }
                            }
                            
                            VStack(alignment: .leading) {
                                Text("\(airline.name)")
                                    .font(.headline)
                                Text("IATA Code: \(airline.iataCode)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 4)
                        }
                        }
            }
            .navigationTitle("Airlines")
        }.onAppear {
            airlineViewModel.loadItems()
        }
    }
}

class AirlineViewModel: PaginatedViewModel {
    var items: [Airline] = []
    
    typealias Item = Airline
    
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false
    
    @Published var page: Int = 1
    @Published var limit: Int = 10
    @Published var hasMore: Bool = false
    @Published var totalCount: Int = 0
    
    private let airlineService = AirlineService()
    
    var canGoBack: Bool {
        page > 1
    }
    
    var canGoForward: Bool {
        self.hasMore
    }
    
    func loadItems() {
        isLoading = true
        
        airlineService.listAirlines(page: page, limit: limit) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let airlines):
                    self?.items = airlines.data
                    self?.page = airlines.pagination.page
                    self?.hasMore = airlines.pagination.hasMore
                    self?.totalCount = airlines.pagination.totalCount
                    
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
