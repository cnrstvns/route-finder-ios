//
//  AppearanceSettingsView.swift
//  RouteFinder
//
//  Created by Connor Stevens on 11/19/24.
//

import Foundation
import SwiftUI

struct AppearanceSettingsView: View {
    @AppStorage("appearanceSetting") private var appearanceSetting: String = "System Default"
    
    var body: some View {
        Form {
            Section(header: Text("Appearance Mode")) {
                Picker("Select Mode", selection: $appearanceSetting) {
                    Text("System Default").tag("System Default")
                    Text("Light").tag("Light")
                    Text("Dark").tag("Dark")
                }
                .pickerStyle(.navigationLink)
            }
        }
        .navigationTitle("Appearance")
        .onChange(of: appearanceSetting) {
            applyAppearanceSetting()
        }
        .onAppear {
            applyAppearanceSetting()
        }
    }
    
    private func applyAppearanceSetting() {
        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
            
        switch appearanceSetting {
        case "Light":
            windowScene?.windows.first?.overrideUserInterfaceStyle = .light
        case "Dark":
            windowScene?.windows.first?.overrideUserInterfaceStyle = .dark
        default:
            windowScene?.windows.first?.overrideUserInterfaceStyle = .unspecified
        }
    }
}

#Preview {
    NavigationStack {
        AppearanceSettingsView()
    }
}
