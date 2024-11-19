//
//  AuthenticationView.swift
//  RouteFinder
//
//  Created by Connor Stevens on 11/18/24.
//

import Foundation
import BetterSafariView
import SwiftUI

struct AuthenticationView: View {
    @State private var presentingWebView = false
    @State private var queryParameters: [String: String] = [:]
    
    var body: some View  {
        Button(action: {
            self.presentingWebView = true
        }) {
            Text("Login with Google")
        }
        .buttonStyle(.borderedProminent)
        .buttonBorderShape(.roundedRectangle(radius: 10))
        .font(.system(size: 18, weight: .semibold))
        .safariView(isPresented: $presentingWebView){
            SafariView(url: URL(string: "https://routes-api.cnrstvns.dev/auth/google/init?redirect=/")!,
                       configuration: SafariView.Configuration(entersReaderIfAvailable: false, barCollapsingEnabled: true)).preferredBarAccentColor(.blue)
                .preferredBarAccentColor(.clear)
                .dismissButtonStyle(.done)
            
        }
        .onOpenURL(perform: { url in
            handleCallbackURL(url: url)
        })
        
        if !queryParameters.isEmpty {
                       Text("Received Parameters:")
                       ForEach(queryParameters.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                           Text("\(key): \(value)")
                       }
                   }
    }
    
    private func handleCallbackURL(url: URL) {
        print(url)
        if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
           let queryItems = components.queryItems {
            // Parse query parameters
            queryParameters = queryItems.reduce(into: [:]) { result, item in
                result[item.name] = item.value
            }
        }
        }
}

#Preview {
    AuthenticationView()
}
