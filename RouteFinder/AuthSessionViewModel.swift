//
//  AuthSessionViewModel.swift
//  RouteFinder
//
//  Created by Connor Stevens on 11/18/24.
//

import Foundation
import SwiftUI

class AuthSessionViewModel: ObservableObject {
    @Published var authSession: AuthSession?
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false

    private let authService = SessionService()

    func loadAuthSession() {
        isLoading = true
        errorMessage = nil

        authService.retrieveSession { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let session):
                    self?.authSession = session
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
}
