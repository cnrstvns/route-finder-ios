//
//  UserRouteService.swift
//  RouteFinder
//
//  Created by Connor Stevens on 11/19/24.
//

import Foundation

struct UserRoute: Decodable, Identifiable {
    let id: Int
    let userId: Int
    let routeId: Int
    let createdAt: Date
}

struct Route: Decodable {
    let id: Int
    let airlineIata: String
    let originIata: String
    let destinationIata: String
    let aircraftCodes: String
    let averageDuration: Int
}

struct ListUserRoute: Decodable, Identifiable {
    let userRoute: UserRoute
    let route: Route
    let airline: Airline
    let origin: Airport
    let destination: Airport
    
    var id: Int {
        userRoute.id
    }
}

struct UserRouteDetails: Decodable, Identifiable {
    let userRoute: UserRoute
    let route: Route
    let airline: Airline
    let origin: Airport
    let destination: Airport
    let aircraft: [Aircraft]
    let distanceInNm: String
    let flightNumber: String
    
    var id: Int {
        userRoute.id
    }
}

struct ToggleUserRouteResponse: Decodable {}

class UserRouteService: BaseService {
    func listUserRoutes(
        page: Int = 1,
        limit: Int = 10,
        query: String? = nil,
        completion: @escaping (Result<PaginatedResponse<ListUserRoute>, Error>) -> Void
    ) {
        var queryParameters: [String: String] = [
            "page": "\(page)",
            "limit": "\(limit)"
        ]
        
        if let query = query {
            queryParameters["q"] = query
        }
        
        makeRequest(
            endpoint: "/v1/user_routes",
            queryParameters: queryParameters,
            completion: completion
        )
    }
    
    func retrieveUserRoute(
        id: Int,
        completion: @escaping (Result<UserRouteDetails, Error>) -> Void
    ) {
        makeRequest(
            endpoint: "/v1/user_routes/\(id)",
            completion: completion
        )
    }
    
    func toggleUserRoute(
        routeId: Int,
        completion: @escaping (Result<ToggleUserRouteResponse, Error>) -> Void
    ) {
        let body: [String: Any] = [
            "routeId": routeId
        ]
        
        makeRequest(
            endpoint: "/v1/user_routes/toggle",
            method: "POST",
            body: body,
            completion: completion
        )
    }
}
