//
//  ImageDataLoader.swift
//  ContactsTechApp
//
//  Created by Joffrey Bocquet on 04/04/2025.
//

import Foundation

final class ImageDataLoader: Sendable {
  private let session: URLSession
  private let cache: URLCache
  
  init(session: URLSession = .shared, cache: URLCache = .shared) {
    self.session = session
    self.cache = cache
  }
  
  func download(url: URL) async throws -> (Data, Bool)? {
    let request = URLRequest(url: url)
    if let cachedData = getCachedData(request: request) {
      return (cachedData, true)
    }
    
    let (data, response) = try await session.data(for: request)
    
    // Check if the response is valid
    guard let httpResponse = response as? HTTPURLResponse,
          httpResponse.statusCode == 200,
          !Task.isCancelled else {
      return nil
    }
    
    save(data: data, for: request, with: httpResponse)
    return (data, false)
  }
  
  private func getCachedData(request: URLRequest) -> Data? {
    return cache.cachedResponse(for: request)?.data
  }
  
  private func save(data: Data,for request: URLRequest, with response: HTTPURLResponse) {
    let cacheResponse = CachedURLResponse(response: response, data: data)
    cache.storeCachedResponse(cacheResponse, for: request)
  }
}
