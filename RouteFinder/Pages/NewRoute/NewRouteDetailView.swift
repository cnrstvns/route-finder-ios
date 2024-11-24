//
//  NewRouteDetailView.swift
//  RouteFinder
//
//  Created by Connor Stevens on 11/23/24.
//

import SwiftUI

struct NewRouteDetailView: View {
    let routeId: Int
    
    @StateObject private var newRouteDetailViewModel = NewRouteDetailViewModel()
    
    var body: some View {
        Group {
            if newRouteDetailViewModel.isLoading {
                ProgressView("Loading...")
                    .progressViewStyle(CircularProgressViewStyle())
                    .padding()
            } else if let route = newRouteDetailViewModel.route {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        // Flight Details Section
                        SectionView(title: "Details") {
                            DetailRow(title: "Airline", value: route.airline.name)
                            DetailRow(title: "Flight Number", value: route.flightNumber)
                            DetailRow(title: "Average Duration", value: formattedDuration(route.route.averageDuration))
                            DetailRow(title: "Distance (Direct)", value: "\(route.distanceInNm) NM")
                            DetailRow(title: "Domestic/International", value: isDomesticFlight(origin: route.origin, destination: route.destination))
                        }
                        
                        // Origin Section
                        SectionView(title: "Origin") {
                            DetailRow(title: "Airport Name", value: route.origin.name)
                            DetailRow(title: "IATA Code", value: route.origin.iataCode)
                            DetailRow(title: "ICAO Code", value: route.origin.icaoCode ?? "N/A")
                            DetailRow(title: "City", value: route.origin.city)
                            DetailRow(title: "Country", value: route.origin.country)
                            DetailRow(title: "Elevation", value: "\(route.origin.elevation ?? "Unknown") feet")
                        }
                        
                        // Destination Section
                        SectionView(title: "Destination") {
                            DetailRow(title: "Airport Name", value: route.destination.name)
                            DetailRow(title: "IATA Code", value: route.destination.iataCode)
                            DetailRow(title: "ICAO Code", value: route.destination.icaoCode ?? "N/A")
                            DetailRow(title: "City", value: route.destination.city)
                            DetailRow(title: "Country", value: route.destination.country)
                            DetailRow(title: "Elevation", value: "\(route.destination.elevation ?? "Unknown") feet")
                        }
                        
                        // Equipment Section
//                        if !route.aircraft.isEmpty {
//                            SectionView(title: "Equipment") {
//                                ForEach(userRoute.aircraft) { aircraft in
//                                    HStack {
//                                        Text(aircraft.modelName)
//                                            .font(.subheadline)
//                                            .padding(.horizontal, 8)
//                                            .padding(.vertical, 4)
//                                            .background(Color.blue.opacity(0.2))
//                                            .foregroundColor(.blue)
//                                            .cornerRadius(8)
//                                        Spacer()
//                                        Text("IATA Code: \(aircraft.iataCode)")
//                                            .font(.footnote)
//                                            .foregroundColor(.secondary)
//                                    }
//                                    .frame(maxWidth: .infinity)
//                                }
//                            }
//                        }
                        
                        SectionView(title: "Export") {
                            VStack(alignment: .leading, spacing: 8) {
                                Link(destination: URL(string: "https://www.simbrief.com/system/dispatch.php?orig=\(route.origin.icaoCode ?? "")&dest=\(route.destination.icaoCode ?? "")")!) {
                                    HStack {
                                        Text("Open in Simbrief")
                                        Image(systemName: "safari.fill")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 20, height: 20)
                                            .padding(.leading, 8)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.black)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                                }
                                
                                Link(destination: URL(string: "https://skyvector.com?fpl=\(route.origin.icaoCode ?? "")%20\(route.destination.icaoCode ?? "")")!) {
                                    HStack {
                                        Text("Open in SkyVector")
                                        Image(systemName: "map")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 20, height: 20)
                                            .padding(.leading, 8)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.black)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                                }
                            }
                        }
                        
                    }
                    .padding(.horizontal)
                }
                .navigationTitle(route.flightNumber.isEmpty ? "Flight Details" : route.flightNumber)
            } else if let errorMessage = newRouteDetailViewModel.errorMessage {
                Text("Error: \(errorMessage)")
                    .foregroundColor(.red)
            } else {
                Text("Loading...")
            }
        }
        .onAppear {
            newRouteDetailViewModel.load(routeId: self.routeId)
        }
    }
}

private class NewRouteDetailViewModel: ObservableObject {
    @Published var route: RetrieveRoute? = nil
    @Published var errorMessage: String? = nil
    @Published var isLoading: Bool = false
    
    private let routeService = RouteService()
    
    func load(routeId: Int) {
        isLoading = true
        
        routeService.retrieveRoute(routeId: routeId) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let route):
                    self?.route = route
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
}

private func formattedDuration(_ minutes: Int) -> String {
    let hours = minutes / 60
    let remainingMinutes = minutes % 60
    var components: [String] = []
    if hours > 0 {
        components.append("\(hours) hour\(hours > 1 ? "s" : "")")
    }
    if remainingMinutes > 0 {
        components.append("\(remainingMinutes) minute\(remainingMinutes > 1 ? "s" : "")")
    }
    return components.joined(separator: " ")
}

private func isDomesticFlight(origin: Airport, destination: Airport) -> String {
    return origin.country == destination.country ? "Domestic" : "International"
}
