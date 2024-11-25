//
//  RouteFinderApp.swift
//  RouteFinder
//
//  Created by Connor Stevens on 11/9/24.
//

import SwiftUI
import UIKit

// Allow the app to have a custom scene delegate
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let configuration = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
        configuration.delegateClass = SceneDelegate.self
        return configuration
    }
}

// Custom scene delegate to handle OAuth callback
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else { return }
        AuthenticationManager.shared.handleCallback(url)
    }
}

@main
struct RouteFinderApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var authManager = AuthenticationManager.shared
    
    var body: some Scene {
        WindowGroup {
            Group {
                if authManager.isCheckingAuthentication {
                    NavigationStack {
                        ProgressView()
                    }
                } else if authManager.isAuthenticated {
                    TabView {
                        Home().tabItem {
                            Image(systemName: "house.fill")
                            Text("Home")
                        }
                        
                        NewRouteView().tabItem {
                            Image(systemName: "magnifyingglass")
                            Text("Find Routes")
                        }
                        
                        SettingsView().tabItem {
                            Image(systemName: "gearshape")
                            Text("Settings")
                        }
                    }
                } else {
                    LoginView()
                        .environmentObject(authManager)
                }
            }.onAppear {
                authManager.checkAuthentication()
            }
        }
    }
}
