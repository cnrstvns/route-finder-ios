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
}

class AirlineService: BaseService {
    func listAirlines(
        page: Int = 1,
        limit: Int = 10,
        completion: @escaping (Result<PaginatedResponse<Airline>, Error>) -> Void
    ) {
        let queryParameters = [
            "page": "\(page)",
            "limit": "\(limit)"
        ]
        makeRequest(
            endpoint: "/v1/airlines",
            queryParameters: queryParameters,
            completion: completion
        )
    }
}
