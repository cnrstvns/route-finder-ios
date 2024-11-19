//
//  AircraftService.swift
//  RouteFinder
//
//  Created by Connor Stevens on 11/19/24.
//

import Foundation

struct Aircraft: Decodable, Identifiable {
    let id: Int
    let iataCode: String
    let modelName: String
    let shortName: String
}

class AircraftService: BaseService {
    func listAircraft(
        page: Int = 1,
        limit: Int = 10,
        completion: @escaping (Result<PaginatedResponse<Aircraft>, Error>) -> Void
    ) {
        let queryParameters = [
            "page": "\(page)",
            "limit": "\(limit)"
        ]
        makeRequest(
            endpoint: "/v1/aircraft",
            queryParameters: queryParameters,
            completion: completion
        )
    }
}
