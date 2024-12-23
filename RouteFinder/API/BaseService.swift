//
//  BaseService.swift
//  RouteFinder
//
//  Created by Connor Stevens on 11/19/24.
//

import Foundation
import SwiftUI

enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case noData
}

struct PaginatedResponse<T: Decodable>: Decodable {
    let data: [T]
    let pagination: Pagination
}

struct Pagination: Decodable {
    let page: Int
    let totalCount: Int
    let hasMore: Bool
}

protocol PaginatedViewModel: ObservableObject {
    associatedtype Item: Identifiable
    var items: [Item] { get }
    var page: Int { get set }
    var limit: Int { get }
    var canGoBack: Bool { get }
    var canGoForward: Bool { get }
    var isLoading: Bool { get }
    func loadItems()
    func nextPage()
    func previousPage()
}

class BaseService {
    private let baseURL: String
    private let urlSession: URLSession
    
    init(baseURL: String = "https://routes-api.cnrstvns.dev", urlSession: URLSession = .shared) {
        self.baseURL = baseURL
        self.urlSession = urlSession
    }
    
    func makeRequest<T: Decodable>(
        endpoint: String,
        method: String = "GET",
        headers: [String: String]? = nil,
        queryParameters: [String: String]? = nil,
        body: [String: Any]? = nil,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        guard var urlComponents = URLComponents(string: "\(baseURL)\(endpoint)") else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        if let queryParameters = queryParameters {
            urlComponents.queryItems = queryParameters.map { URLQueryItem(name: $0.key, value: $0.value) }
        }
        
        guard let url = urlComponents.url else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        headers?.forEach { key, value in
            request.addValue(value, forHTTPHeaderField: key)
        }
        
        #if DEBUG
        // In development, do not cache responses
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        #else
        // In production, use caching
        request.cachePolicy = .returnCacheDataElseLoad
        #endif
        
        if let token = AuthenticationManager.shared.getToken() {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        // Encode body if present
         if let body = body {
             do {
                 request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
                 request.addValue("application/json", forHTTPHeaderField: "Content-Type")
             } catch {
                 completion(.failure(error))
                 return
             }
         }
        
        let task = urlSession.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NetworkError.invalidResponse))
                return
            }
            
            let validStatusCodes = [200, 201, 204]
            guard validStatusCodes.contains(httpResponse.statusCode) else {
                completion(.failure(NetworkError.invalidResponse))
                return
            }
            
            if httpResponse.statusCode == 204 {
                completion(.success(() as! T))
                return
            }
            
            guard let data = data else {
                completion(.failure(NetworkError.noData))
                return
            }
            
            if let rawJSON = String(data: data, encoding: .utf8) {
                print("Raw JSON response: \(rawJSON)")
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .custom { decoder -> Date in
                    let container = try decoder.singleValueContainer()
                    let isoFormatter = ISO8601DateFormatter()
                    isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                    let dateString = try container.decode(String.self)
                    if let date = isoFormatter.date(from: dateString) {
                        return date
                    }
                    throw DecodingError.dataCorruptedError(
                        in: container,
                        debugDescription: "Expected date string to be ISO8601-formatted with fractional seconds."
                    )
                }
                let decodedResponse = try decoder.decode(T.self, from: data)
                completion(.success(decodedResponse))
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
}
