//
//  AirlineView.swift
//  RouteFinder
//
//  Created by Connor Stevens on 11/19/24.
//

import Foundation
import SwiftUI
import Combine
import Kingfisher

struct AirlineView: View {
    @StateObject private var airlineViewModel = AirlineViewModel()
    @State private var isSearching = false
    @State private var searchText = ""
    @FocusState private var isSearchFocused: Bool
    
    var body: some View {
        NavigationStack {
            VStack {
                if isSearching {
                    TextField("Search airlines...", text: $searchText)
                        .padding(.init(top: 12, leading: 16, bottom: 12, trailing: 16))
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(isSearchFocused ? Color.indigo : Color.gray, lineWidth: 1.5)
                        )
                        .padding(.horizontal)
                        .submitLabel(.done)
                        .onChange(of: searchText) { _, newValue in
                            airlineViewModel.setQuery(query: newValue)
                        }
                        .focused($isSearchFocused)
     
                }
                
                PaginationView(viewModel: airlineViewModel) { airline in
                    HStack(spacing: 12) {
                        VStack(alignment: .leading) {
                            if let url = URL(string: airline.logoPath) {
                                KFImage(url)
                                    .placeholder {
                                        ProgressView()
                                    }
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 50, height: 50)
                                    .clipShape(Circle())
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
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        isSearching.toggle()
                        isSearchFocused.toggle()
                        
                        if !airlineViewModel.query.isEmpty {
                            airlineViewModel.setQuery(query: "")
                            searchText = ""
                        }
                    }) {
                        Image(systemName: "magnifyingglass")
                            .padding(10)
                    }
                }
            }
            .onAppear {
                airlineViewModel.loadItems()
            }
        }
    }
}

private class AirlineViewModel: PaginatedViewModel {
    var items: [Airline] = []
    
    typealias Item = Airline
    
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false
    
    @Published var page: Int = 1
    @Published var limit: Int = 10
    @Published var hasMore: Bool = false
    @Published var totalCount: Int = 0
    
    @Published var query: String = ""
    
    private let airlineService = AirlineService()
    private var searchTimer: Timer?
    
    var canGoBack: Bool {
        page > 1
    }
    
    var canGoForward: Bool {
        self.hasMore
    }
    
    func loadItems() {
        isLoading = true
        
        airlineService.listAirlines(page: page, limit: limit, query: query) { [weak self] result in
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
    
    func setQuery(query: String) {
        searchTimer?.invalidate()
        
        self.page = 1
        
        searchTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { [weak self] _ in
            self?.query = query
            self?.page = 1
            self?.loadItems()
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
