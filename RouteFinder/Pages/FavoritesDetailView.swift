//
//  FavoritesDetailView.swift
//  RouteFinder
//
//  Created by Connor Stevens on 11/20/24.
//

import SwiftUI

struct FavoritesDetailView: View {
    let userRouteId: Int
    
    @StateObject private var userRouteDetailsViewModel = UserRouteDetailsViewModel()
    
    var body: some View {
        Group {
            if userRouteDetailsViewModel.isLoading {
                ProgressView("Loading...")
                    .progressViewStyle(CircularProgressViewStyle())
                    .padding()
            } else if let userRoute = userRouteDetailsViewModel.userRoute {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        // Flight Details Section
                        SectionView(title: "Details") {
                            DetailRow(title: "Airline", value: userRoute.airline.name)
                            DetailRow(title: "Flight Number", value: userRoute.flightNumber)
                            DetailRow(title: "Average Duration", value: formattedDuration(userRoute.route.averageDuration))
                            DetailRow(title: "Distance (Direct)", value: "\(userRoute.distanceInNm) NM")
                            DetailRow(title: "Domestic/International", value: isDomesticFlight(origin: userRoute.origin, destination: userRoute.destination))
                        }
                        
                        // Origin Section
                        SectionView(title: "Origin") {
                            DetailRow(title: "Airport Name", value: userRoute.origin.name)
                            DetailRow(title: "IATA Code", value: userRoute.origin.iataCode)
                            DetailRow(title: "ICAO Code", value: userRoute.origin.icaoCode ?? "N/A")
                            DetailRow(title: "City", value: userRoute.origin.city)
                            DetailRow(title: "Country", value: userRoute.origin.country)
                            DetailRow(title: "Elevation", value: "\(userRoute.origin.elevation ?? "Unknown") feet")
                        }
                        
                        // Destination Section
                        SectionView(title: "Destination") {
                            DetailRow(title: "Airport Name", value: userRoute.destination.name)
                            DetailRow(title: "IATA Code", value: userRoute.destination.iataCode)
                            DetailRow(title: "ICAO Code", value: userRoute.destination.icaoCode ?? "N/A")
                            DetailRow(title: "City", value: userRoute.destination.city)
                            DetailRow(title: "Country", value: userRoute.destination.country)
                            DetailRow(title: "Elevation", value: "\(userRoute.destination.elevation ?? "Unknown") feet")
                        }
                        
                        // Equipment Section
                        if !userRoute.aircraft.isEmpty {
                            SectionView(title: "Equipment") {
                                ForEach(userRoute.aircraft) { aircraft in
                                    HStack {
                                        Text(aircraft.modelName)
                                            .font(.subheadline)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(Color.blue.opacity(0.2))
                                            .foregroundColor(.blue)
                                            .cornerRadius(8)
                                        Spacer()
                                        Text("IATA Code: \(aircraft.iataCode)")
                                            .font(.footnote)
                                            .foregroundColor(.secondary)
                                    }
                                    .frame(maxWidth: .infinity)
                                }
                            }
                        }
                        
                        SectionView(title: "Export") {
                            VStack(alignment: .leading, spacing: 8) {
                                Link(destination: URL(string: "https://www.simbrief.com/system/dispatch.php?orig=\(userRoute.origin.icaoCode ?? "")&dest=\(userRoute.destination.icaoCode ?? "")")!) {
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
                                
                                Link(destination: URL(string: "https://skyvector.com?fpl=\(userRoute.origin.icaoCode ?? "")%20\(userRoute.destination.icaoCode ?? "")")!) {
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
                .navigationTitle(userRoute.flightNumber.isEmpty ? "Flight Details" : userRoute.flightNumber)
            } else if let errorMessage = userRouteDetailsViewModel.errorMessage {
                Text("Error: \(errorMessage)")
                    .foregroundColor(.red)
            } else {
                Text("Loading route details...")
                    .foregroundColor(.gray)
                    .padding()
            }
        }
        .onAppear {
            if userRouteDetailsViewModel.userRoute == nil && !userRouteDetailsViewModel.isLoading {
                userRouteDetailsViewModel.load(userRouteId: self.userRouteId)
            }
        }
    }
}

private class UserRouteDetailsViewModel: ObservableObject {
    @Published var userRoute: UserRouteDetails? = nil
    @Published var errorMessage: String? = nil
    @Published var isLoading: Bool = false
    
    private let userRouteService = UserRouteService()
    
    func load(userRouteId: Int) {
        isLoading = true
        userRouteService.retrieveUserRoute(id: userRouteId) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let userRoute):
                    self?.userRoute = userRoute
                    print(userRoute)
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
    return "\(hours)h \(remainingMinutes)m"
}

private func isDomesticFlight(origin: Airport, destination: Airport) -> String {
    origin.country == destination.country ? "Domestic" : "International"
}

struct SectionView<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.title2)
                .bold()
                .padding(.bottom, 4)
            VStack(alignment: .leading, spacing: 8) {
                content
            }
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(8)
        }
    }
}
