//
//  SessionService.swift
//  RouteFinder
//
//  Created by Connor Stevens on 11/19/24.
//

import Foundation


struct AuthSession: Decodable {
    let id: Int
    let emailAddress: String
    let profilePictureUrl: String?
    let admin: Bool
    let firstName: String?
    let lastName: String?
    let updatedAt: Date
    let createdAt: Date
}

class SessionService: BaseService {
    func retrieveSession(completion: @escaping (Result<AuthSession, Error>) -> Void) {
        makeRequest(endpoint: "/auth/session", completion: completion)
    }
}
