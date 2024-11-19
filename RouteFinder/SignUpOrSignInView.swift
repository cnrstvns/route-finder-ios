//
//  SignUpOrSignInView.swift
//  RouteFinder
//
//  Created by Connor Stevens on 11/9/24.
//

import SwiftUI

struct SignUpOrSignInView: View {
  @State private var isSignUp = true
  @State private var isOAuth = false

  var body: some View {
    ScrollView {
      if isSignUp {
        SignUpView()
      } else if isOAuth {
        OAuthView()
      } else {
        SignInView()
      }

      Button {
        isSignUp.toggle()
      } label: {
        if isSignUp {
          Text("Already have an account? Sign In")
        } else {
          Text("Don't have an account? Sign Up")
        }
      }
      .padding()
        
        Button {
            isOAuth.toggle()
        } label: {
            Text("Sign in with Google")
        }.padding()
    }
  }
}
