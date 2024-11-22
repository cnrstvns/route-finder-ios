//
//  AirportService.swift
//  RouteFinder
//
//  Created by Connor Stevens on 11/19/24.
//

import Foundation

enum AirportSize: String, Decodable {
    case small
    case medium
    case large
}

struct Airport: Decodable, Identifiable {
    let id: Int
    let iataCode: String
    let icaoCode: String?
    let name: String
    let city: String
    let country: String
    let latitude: String
    let longitude: String
    let elevation: String?
    let size: AirportSize?
}

class AirportService: BaseService {
    func listAirports(
        page: Int = 1,
        limit: Int = 10,
        query: String? = nil,
        completion: @escaping (Result<PaginatedResponse<Airport>, Error>) -> Void
    ) {
        var queryParameters: [String: String] = [
            "page": "\(page)",
            "limit": "\(limit)"
        ]
        
        if let query = query {
            queryParameters["q"] = query
        }
        
        makeRequest(
            endpoint: "/v1/airports",
            queryParameters: queryParameters,
            completion: completion
        )
    }
    
    func retrieveAirport(
        id: Int,
        completion: @escaping (Result<Airport, Error>) -> Void
    ) {
        makeRequest(
            endpoint: "/v1/airports/\(id)",
            completion: completion
        )
    }
}
