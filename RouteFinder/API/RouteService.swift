//
//  RouteService.swift
//  RouteFinder
//
//  Created by Connor Stevens on 11/22/24.
//

import Foundation

struct SearchRoute: Decodable, Identifiable {
    let id: Int
    let airlineIata: String
    let originIata: String
    let destinationIata: String
    let averageDuration: Int
    let originName: String?
    let destinationName: String?
    var userRouteId: Int?
    var userRouteUserId: Int?
    var userRouteCreatedAt: String?
    let matchingAircraftCodes: [String]
    let nonMatchingAircraftCodes: [String]
}

struct RetrieveRoute: Decodable, Identifiable {
    let route: Route
    let airline: Airline
    let origin: Airport
    let destination: Airport
    let userRoute: UserRoute?
    let flightNumber: String
    let distanceInNm: String
    
    var id: Int {
        route.id
    }
}

class RouteService: BaseService {
    /// Search for routes based on parameters
    /// - Parameters:
    ///   - aircraft: The aircraft IATA code(s)
    ///   - airline: The airline IATA code
    ///   - minDuration: The minimum flight duration
    ///   - maxDuration: The maximum flight duration
    ///   - page: The page number for pagination
    ///   - limit: The number of items per page
    ///   - completion: A closure that returns a `Result` containing `PaginatedResponse<Route>` or an `Error`
    func searchRoutes(
        aircraft: String,
        airline: String,
        minDuration: Double,
        maxDuration: Double,
        page: Int = 1,
        limit: Int = 10,
        completion: @escaping (Result<PaginatedResponse<SearchRoute>, Error>) -> Void
    ) {
        let queryParameters: [String: String] = [
            "aircraft": aircraft,
            "airline": airline,
            "minDuration": String(minDuration),
            "maxDuration": String(maxDuration),
            "page": "\(page)",
            "limit": "\(limit)"
        ]

        makeRequest(
            endpoint: "/v1/routes/search",
            queryParameters: queryParameters,
            completion: completion
        )
    }
    
    func retrieveRoute(
        routeId: Int,
        completion: @escaping (Result<RetrieveRoute, Error>) -> Void
    ) {
        makeRequest(
            endpoint: "/v1/routes/\(routeId)",
            completion: completion
        )
    }
}
