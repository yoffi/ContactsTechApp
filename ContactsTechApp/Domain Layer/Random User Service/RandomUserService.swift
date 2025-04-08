//
//  RandomUserService.swift
//  ContactsTechApp
//
//  Created by Joffrey Bocquet on 03/04/2025.
//

/// Concrete class implementation that fetch data over HTTP network request
final class RandomUserService: RandomUserServiceInterface {
  private let apiClient: any HTTPClientInterface

  init(apiClient: any HTTPClientInterface) {
    self.apiClient = apiClient
  }
  
  func fetchUsers(page: Int) async throws -> [any UserInterface] {
    let request = JSONHTTPClient.JSONRequest(
      method: .get,
      endpoint: "/api/?page=\(page)&results=10&seed=technicaltest"
    )
    
    let result: Result<Response, HTTPClientError> = try await apiClient.execute(request)
    switch result {
      case .success(let response):
        return response.results
      case .failure(let error):
        throw error
    }
  }
  
  func fetchUser(id: String) async throws -> any UserInterface {
    let request = JSONHTTPClient.JSONRequest(
      method: .get,
      endpoint: "/api/"
    )
    
    let result: Result<Response, HTTPClientError> = try await apiClient.execute(request)
    switch result {
      case .success(let response):
        return response.results.first!
      case .failure(let error):
        throw error
    }
  }
}
