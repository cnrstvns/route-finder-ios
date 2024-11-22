//
//  NewRouteView.swift
//  RouteFinder
//
//  Created by Connor Stevens on 11/21/24.
//

import SwiftUI

struct NewRouteView: View {
    @State private var currentStep: Int = 1
    
    var body: some View {
        NavigationStack {
            VStack {
                // Step Content
                switch currentStep {
                case 1:
                    ChooseAirlineView()
                case 2:
                    StepTwoView(currentStep: $currentStep)
                case 3:
                    StepThreeView(currentStep: $currentStep)
                default:
                    Text("Invalid Step")
                }
            }
            .navigationTitle("New Route")
        }
    }
}

// Step 2 View: Choose Criteria
struct StepTwoView: View {
    @Binding var currentStep: Int
    
    var body: some View {
        VStack {
            Text("Step 2: Choose Criteria")
                .font(.headline)
                .padding(.bottom)
            List {
                ForEach(["Price", "Duration", "Stops"], id: \.self) { criteria in
                    Button(action: {
                        // Handle selection
                        currentStep = 3
                    }) {
                        Text(criteria)
                    }
                }
            }
        }
    }
}

// Step 3 View: View Results
struct StepThreeView: View {
    @Binding var currentStep: Int
    
    var body: some View {
        VStack {
            Text("Step 3: View Results")
                .font(.headline)
                .padding(.bottom)
            List {
                ForEach(["Result 1", "Result 2", "Result 3"], id: \.self) { result in
                    Text(result)
                }
            }
        }
    }
}

#Preview {
    NewRouteView()
}
