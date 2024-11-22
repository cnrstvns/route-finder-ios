//
//  AirlineService.swift
//  RouteFinder
//
//  Created by Connor Stevens on 11/19/24.
//

import Foundation

struct Airline: Identifiable, Decodable {
    let id: Int
    let slug: String
    let name: String
    let iataCode: String
    let logoPath: String
    let routeCount: Int?
}

struct ListAirlineAircraft: Decodable, Hashable {
    let modelName: String
    let iataCode: String
}

struct ListAirlineAircraftResponse: Decodable {
    let airline: Airline
    let aircraft: [ListAirlineAircraft]
}

class AirlineService: BaseService {
    func listAirlines(
        page: Int = 1,
        limit: Int = 10,
        query: String?,
        completion: @escaping (Result<PaginatedResponse<Airline>, Error>) -> Void
    ) {
        let queryParameters = [
            "page": "\(page)",
            "limit": "\(limit)",
            "q": "\(query ?? "")"
        ]
        makeRequest(
            endpoint: "/v1/airlines",
            queryParameters: queryParameters,
            completion: completion
        )
    }
    
    func listAirlineAircraft(
        airlineId: Int,
        completion: @escaping (Result<ListAirlineAircraftResponse, Error>) -> Void
    ) {
        makeRequest(
            endpoint: "/v1/airlines/\(airlineId)/aircraft",
            completion: completion
        )
    }
    
}
