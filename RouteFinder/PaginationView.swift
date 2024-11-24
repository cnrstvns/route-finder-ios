//
//  PaginationView.swift
//  RouteFinder
//
//  Created by Connor Stevens on 11/19/24.
//

import Foundation
import SwiftUI

struct PaginationView<ViewModel: PaginatedViewModel, Content: View>: View {
    @ObservedObject var viewModel: ViewModel
    let content: (ViewModel.Item) -> Content
    
    var body: some View {
        NavigationStack {
            VStack {
                if viewModel.isLoading {
                    List(0..<10, id: \.self) { _ in
                        SkeletonRow()
                    }
                } else if viewModel.items.isEmpty {
                    Text("No items available.")
                        .foregroundColor(.gray)
                } else {
                    List(viewModel.items) { item in
                        content(item)
                    }
                }
                
                // Pagination Controls with Centered Page Number
                ZStack {
                    HStack {
                        Button("Previous") {
                            viewModel.previousPage()
                        }
                        .disabled(viewModel.isLoading || !viewModel.canGoBack)
                        
                        Spacer()
                        
                        Button("Next") {
                            viewModel.nextPage()
                        }
                        .disabled(viewModel.isLoading || !viewModel.canGoForward)
                    }
                    .padding()
                    
                    Text("Page \(viewModel.page)")
                        .font(.headline)
                        .frame(maxWidth: .infinity) // Ensures it's centered within the ZStack
                        .multilineTextAlignment(.center)
                }
            }
        }
    }
}

struct SkeletonRow: View {
    var body: some View {
        HStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.gray.opacity(0.3))
                .frame(width: 50, height: 50)
            
            VStack(alignment: .leading, spacing: 8) {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 20)
                
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 14)
                    .padding(.trailing, 50)
            }
        }
        .padding(.vertical, 8)
    }
}
