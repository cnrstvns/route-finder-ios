//
//  Aircraft.swift
//  RouteFinder
//
//  Created by Connor Stevens on 11/19/24.
//

import Foundation
import SwiftUI

struct AircraftView: View {
    @StateObject private var aircraftViewModel = AircraftViewModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                PaginationView(viewModel: aircraftViewModel) { aircraft in
                    VStack(alignment: .leading) {
                        Text(aircraft.modelName)
                            .font(.headline)
                        Text("IATA Code: \(aircraft.iataCode)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Aircraft")
        }.onAppear {
            aircraftViewModel.loadItems()
        }
    }
}

class AircraftViewModel: PaginatedViewModel {
    var items: [Aircraft] = []
    
    typealias Item = Aircraft
    
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false
    
    @Published var page: Int = 1
    @Published var limit: Int = 10
    @Published var hasMore: Bool = false
    @Published var totalCount: Int = 0
    
    private let aircraftService = AircraftService()
    
    var canGoBack: Bool {
        page > 1
    }
    
    var canGoForward: Bool {
        self.hasMore
    }
    
    func loadItems() {
        isLoading = true
        
        aircraftService.listAircraft(page: page, limit: limit) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let aircraft):
                    self?.items = aircraft.data
                    self?.page = aircraft.pagination.page
                    self?.hasMore = aircraft.pagination.hasMore
                    self?.totalCount = aircraft.pagination.totalCount
                    
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

struct AircraftView_Previews: PreviewProvider {
    static var previews: some View {
        AircraftView()
    }
}
