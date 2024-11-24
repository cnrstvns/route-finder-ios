//
//  AuthenticationManager.swift
//  RouteFinder
//
//  Created by Connor Stevens on 11/18/24.
//

import SwiftUI
import SafariServices
import Security

// Authentication manager to handle OAuth flow and token storage
class AuthenticationManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var authError: String?
    @Published var isCheckingAuthentication = true
    
    private let baseURL = "https://routes-api.cnrstvns.dev"
    
    static let shared = AuthenticationManager()
    private var safariVC: SFSafariViewController?
    
    
    // MARK: - OAuth Methods
    
    func initiateGoogleAuth() {
        initiateOAuth(provider: "google")
    }
    
    func initiateDiscordAuth() {
        initiateOAuth(provider: "discord")
    }
    
    private func initiateOAuth(provider: String) {
        // Construct the OAuth URL with the redirect back to our app
        let redirectScheme = "routefinder" // You'll need to configure this in your Info.plist
        let redirectURL = "\(redirectScheme)://oauth-callback"
        let encodedRedirect = redirectURL.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
        
        let authURL = "\(baseURL)/auth/\(provider)/init?redirect=\(encodedRedirect)"
        
        if let url = URL(string: authURL) {
            // Present the SFSafariViewController
            DispatchQueue.main.async {
                self.safariVC = SFSafariViewController(url: url)
                
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let rootViewController = windowScene.windows.first?.rootViewController {
                    // Present the Safari View Controller
                    rootViewController.present(self.safariVC!, animated: true)
                }
            }
        }
    }
    
    func handleCallback(_ url: URL) {
        // First, dismiss the Safari View Controller
        DispatchQueue.main.async { [weak self] in
            self?.safariVC?.dismiss(animated: true) {
                self?.safariVC = nil
            }
            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootViewController = windowScene.windows.first?.rootViewController {
                rootViewController.dismiss(animated: true)
            }
        }
        
        if let token = extractToken(from: url) {
            saveToken(token)
        } else {
            DispatchQueue.main.async {
                self.authError = "Failed to extract token from URL"
            }
        }
    }
    
    private func extractToken(from url: URL) -> String? {
        // First try query parameters
        if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
           let queryItems = components.queryItems,
           let token = queryItems.first(where: { $0.name == "token" })?.value {
            return token
        }
        
        // If no token in query params, try checking the fragment
        if let fragment = url.fragment,
           fragment.contains("token=") {
            let parts = fragment.components(separatedBy: "=")
            if parts.count > 1 {
                return parts[1]
            }
        }
        
        return nil
    }
    
    
    // MARK: - Token Management
    
    func saveToken(_ token: String) {
        let query: [String: Any] = [
            kSecValueData as String: token.data(using: .utf8)!,
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: "com.cnrstvns.RouteFinder",
            kSecAttrAccount as String: "AuthToken",
        ]
        
        SecItemDelete(query as CFDictionary)
        let status = SecItemAdd(query as CFDictionary, nil)
        
        if status == errSecSuccess {
            DispatchQueue.main.async {
                self.isAuthenticated = true
            }
        }
    }
    
    func getToken() -> String? {
        let query: [String: Any] = [
            kSecAttrService as String: "com.cnrstvns.RouteFinder",
            kSecAttrAccount as String: "AuthToken",
            kSecClass as String: kSecClassGenericPassword,
            kSecReturnData as String: true
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        if status == errSecSuccess,
           let data = result as? Data,
           let token = String(data: data, encoding: .utf8) {
            return token
        }
        return nil
    }
    
    func clearToken() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "AuthToken"
        ]
        
        SecItemDelete(query as CFDictionary)
        DispatchQueue.main.async {
            self.isAuthenticated = false
        }
    }
    
    func checkAuthentication() {
        if let _ = getToken() {
            DispatchQueue.main.async {
                self.isAuthenticated = true
            }
        } else {
            DispatchQueue.main.async {
                self.isAuthenticated = false
            }
        }
        
        self.isCheckingAuthentication = false
    }
}
