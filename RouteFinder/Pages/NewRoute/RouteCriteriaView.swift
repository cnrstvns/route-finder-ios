//
//  RouteCriteriaView.swift
//  RouteFinder
//
//  Created by Connor Stevens on 11/21/24.
//

import SwiftUI

struct RouteCriteriaView: View {
    var airlineId: Int
    var airlineIata: String
    
    @StateObject private var routeCriteriaViewModel = RouteCriteriaViewModel()
    @State private var selectedAircraft: Set<ListAirlineAircraft> = []
    @State private var minDuration: Double = 0.5
    @State private var maxDuration: Double = 20.0
    @ObservedObject var slider = CustomSlider(start: 0, end: 20, width: 0)
    
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
                    List {
                        Section(header: Text("Choose an Aircraft")) {
                            ForEach(data.aircraft, id: \.self) { aircraft in
                                HStack {
                                    Text(aircraft.modelName)
                                    Spacer()
                                    
                                    if selectedAircraft.contains(aircraft) {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.blue)
                                    }
                                }
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    if selectedAircraft.contains(aircraft) {
                                        selectedAircraft.remove(aircraft)
                                    } else {
                                        selectedAircraft.insert(aircraft)
                                    }
                                }
                            }
                            .environment(\.editMode, .constant(.active))
                        }
                        
                        Section(header: Text("Select Flight Duration")) {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Duration: \(String(format: "%.1f", slider.lowHandle.currentValue)) - \(String(format: "%.1f", slider.highHandle.currentValue)) hours")
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                SliderView(slider: slider)
                                    .frame(maxWidth: .infinity)
                                    .padding(.top, 8)
                                    .padding(.horizontal, 8)
                            }
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity)
                        }
                    }
                    
                    Spacer()
                    
                    HStack {
                        NavigationLink(
                            destination: NewRouteResultsView(
                                airlineIata: airlineIata,
                                minDuration: slider.lowHandle.currentValue,
                                maxDuration: slider.highHandle.currentValue,
                                aircraftCodes: selectedAircraft.map { $0.iataCode }
                            )
                        ) {
                            HStack {
                                Image(systemName: "magnifyingglass")
                                Text("Find Routes")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(selectedAircraft.isEmpty ? Color.gray.opacity(0.5) : Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .disabled(selectedAircraft.isEmpty)
                            .font(.system(size: 18, weight: .medium))
                        }
                    }
                    .padding()
                } else {
                    Text("No data available.")
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
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
                    self?.errorMessage = "Something went wrong"
                }
            }
        }
    }
}
