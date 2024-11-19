//
//  LoginView.swift
//  RouteFinder
//
//  Created by Connor Stevens on 11/18/24.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Text("RouteFinder")
                .font(.largeTitle)
                .bold()
            
            
            
            Button(action: {
                authManager.initiateGoogleAuth()
            }) {
                HStack {
                    Image(systemName: "g.circle.fill")
                    Text("Sign in with Google")
                        .fontWeight(.medium)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            
            Button(action: {
                authManager.initiateDiscordAuth()
            }) {
                HStack {
                    Image(systemName: "bubble.left.fill")
                    Text("Sign in with Discord")
                        .fontWeight(.medium)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.indigo)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            
            Spacer()
            
            Text("Copyright 2024, Connor Stevens")
                .foregroundStyle(.gray)
                .font(.system(size: 14))
        }
        .padding()
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthenticationManager())
}
