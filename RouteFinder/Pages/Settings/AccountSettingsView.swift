//
//  AccountSettingsView.swift
//  RouteFinder
//
//  Created by Connor Stevens on 11/19/24.
//

import SwiftUI

struct AccountSettingsView: View {
    @State private var firstName: String
    @State private var lastName: String
    
    private let initialFirstName: String
    private let initialLastName: String
    
    init(profile: AuthSession) {
        _firstName = State(initialValue: profile.firstName ?? "")
        _lastName = State(initialValue: profile.lastName ?? "")
        initialFirstName = profile.firstName ?? ""
        initialLastName = profile.lastName ?? ""
    }
    
    private var isDirty: Bool {
        firstName != initialFirstName || lastName != initialLastName
    }
    
    var body: some View {
        Form {
            Section(header: Text("Personal Information")) {
                TextField("First Name", text: $firstName)
                    .autocapitalization(.words)
                    .textInputAutocapitalization(.words)
                    .disableAutocorrection(true)
                
                TextField("Last Name", text: $lastName)
                    .autocapitalization(.words)
                    .textInputAutocapitalization(.words)
                    .disableAutocorrection(true)
            }

            Section {
                Button(action: {
                    print(firstName, lastName)
                }) {
                    Text("Save Changes")
                }.disabled(!isDirty)
            } 
        }
        .navigationTitle("Account Settings")
    }
}

#Preview {
    NavigationStack {
        AccountSettingsView(profile: AuthSession(id: 1, emailAddress: "user@example.com", profilePictureUrl: nil, admin: false, firstName: "John", lastName: "Doe", updatedAt: Date(), createdAt: Date()))
    }
}
