//
//  OAuthView.swift
//  RouteFinder
//
//  Created by Connor Stevens on 11/9/24.
//

import SwiftUI
import ClerkSDK

struct OAuthView: View {
  var body: some View {
    // Render a button for each supported OAuth provider
    // you want to add to your app. This example uses only Google.
    Button("Sign In with Google") {
      Task { await signInWithOAuth(provider: .google) }
    }
  }
}

extension OAuthView {

  func signInWithOAuth(provider: OAuthProvider) async {
    do {
      // Start the sign-in process using the selected OAuth provider.
      let signIn = try await SignIn.create(strategy: .oauth(provider))

      // Start the OAuth process
      let externalAuthResult = try await signIn.authenticateWithRedirect()

      // It is common for users who are authenticating with OAuth to use
      // a sign-in button when they mean to sign-up, and vice versa.
      // Clerk will handle this transfer for you if possible.
      // Therefore, an ExternalAuthResult can contain either a SignIn or SignUp.

      // Check if the result of the OAuth was a sign in
      if let signIn = externalAuthResult.signIn {
        switch signIn.status {
        case .complete:
          // If sign-in process is complete, navigate the user as needed.
          await dump(Clerk.shared.session)
        default:
          // If the status is not complete, check why. User may need to
          // complete further steps.
          dump(signIn.status)
        }
      }

      // Check if the result of the OAuth was a sign up
      if let signUp = externalAuthResult.signUp {
        switch signUp.status {
        case .complete:
          // If sign-up process is complete, navigate the user as needed.
          await dump(Clerk.shared.session)
        default:
          // If the status is not complete, check why. User may need to
          // complete further steps.
          dump(signUp.status)
        }
      }
    } catch {
      // See https://clerk.com/docs/custom-flows/error-handling
      // for more info on error handling.
      dump(error)
    }
  }
}
