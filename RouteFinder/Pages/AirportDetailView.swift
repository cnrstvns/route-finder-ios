//
//  AirportDetailView.swift
//  RouteFinder
//
//  Created by Connor Stevens on 11/19/24.
//

import SwiftUI

struct AirportDetailView: View {
    let airport: Airport
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Title
                Text(airport.name)
                    .font(.largeTitle)
                    .bold()
                
                Text("\(airport.city), \(airport.country)")
                    .font(.title3)
                    .foregroundColor(.secondary)
                
                Divider()
                
                Group {
                    DetailRow(title: "IATA Code", value: airport.iataCode)
                    
                    if let icao = airport.icaoCode {
                        DetailRow(title: "ICAO Code", value: icao)
                    }
                    
                    DetailRow(title: "Latitude", value: airport.latitude)
                    DetailRow(title: "Longitude", value: airport.longitude)
                    
                    if let elevation = airport.elevation {
                        DetailRow(title: "Elevation", value: "\(elevation) ft")
                    }
                    
                    if let size = airport.size {
                        DetailRow(title: "Size", value: size.rawValue.capitalized)
                    }
                }
            }
            .padding()
        }
    }
}

struct DetailRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title + ":")
                .font(.headline)
            Spacer()
            Text(value)
                .font(.body)
                .foregroundColor(.secondary)
                .textSelection(.enabled)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    let mockAirport = Airport(
        id: 1,
        iataCode: "LAX",
        icaoCode: "KLAX",
        name: "Los Angeles International Airport",
        city: "Los Angeles",
        country: "United States",
        latitude: "33.9416",
        longitude: "-118.4085",
        elevation: "125",
        size: .large
    )
    return AirportDetailView(airport: mockAirport)
}
