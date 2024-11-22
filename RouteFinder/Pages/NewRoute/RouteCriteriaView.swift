//
//  RouteCriteriaView.swift
//  RouteFinder
//
//  Created by Connor Stevens on 11/21/24.
//

import SwiftUI

struct RouteCriteriaView: View {
    var airlineId: Int
    
    @StateObject private var routeCriteriaViewModel = RouteCriteriaViewModel()
    @State private var selectedAircraft: Set<ListAirlineAircraft> = []
    
    var body: some View {
        NavigationStack {
            Text("Choose your aircraft and flight length")
                .foregroundStyle(.gray)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading)
            
            VStack(alignment: .leading) {
                if routeCriteriaViewModel.isLoading {
                    Text("Loading....")
                        .frame(maxWidth: .infinity, alignment: .center)
                } else if let data = routeCriteriaViewModel.data {
                    List(data.aircraft, id: \.self, selection: $selectedAircraft) { aircraft in
                        HStack {
                            Text(aircraft.modelName)
                        }
                        .contentShape(Rectangle()) // Make the whole row tappable
                        .onTapGesture {
                            if selectedAircraft.contains(aircraft) {
                                selectedAircraft.remove(aircraft)
                            } else {
                                selectedAircraft.insert(aircraft)
                            }
                        }
                    }
                    .environment(\.editMode, .constant(.active)) // Enable multiselect mode
                } else {
                    Text("No data available.")
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .padding()
            .navigationTitle((routeCriteriaViewModel.data != nil) ? "New \(routeCriteriaViewModel.data?.airline.iataCode ?? "") flight" : "Loading...")
            .onAppear {
                routeCriteriaViewModel.loadItems(airlineId: airlineId)
            }
        }
    }
}

private class RouteCriteriaViewModel: ObservableObject {
    @Published var data: ListAirlineAircraftResponse?
    
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false
    
    private let airlineService = AirlineService()
    
    func loadItems(airlineId: Int) {
        isLoading = true
        
        airlineService.listAirlineAircraft(airlineId: airlineId) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let airline):
                    self?.data = airline
                    
                case .failure(let error) :
                    print(error)
                    self?.errorMessage = "Something went wrong"
                }
            }
        }
    }
}
