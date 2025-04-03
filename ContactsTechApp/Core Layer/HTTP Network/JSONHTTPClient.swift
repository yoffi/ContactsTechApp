//
//  JSONHTTPClient.swift
//  ContactsTechApp
//
//  Created by Joffrey Bocquet on 03/04/2025.
//

import Foundation

/// A light simple Web HTTP Notworking client for JSON Content type.
public class JSONHTTPClient: HTTPClientInterface {
  public typealias RequestType = JSONRequest
  
  public let session: URLSession
  public let baseURL: URL
  public let decoder: JSONDecoder = JSONDecoder()
  public let encoder: JSONEncoder = JSONEncoder()
  
  init(session: URLSession = .shared, baseURL: String) throws {
    self.session = session
    if let baseURL = URL(string: baseURL) {
      self.baseURL = baseURL
    } else {
      throw HTTPClientError.baseUrlBuildingFailed
    }
  }
  
  // MARK: - Execute Request
  
  public func execute<T: Decodable>(_ request: any HTTPRequestInterface) async throws -> Result<T, HTTPClientError> {
    return try await execute(request, decode: decode)
  }
  
  private func execute<T: Decodable>(
    _ request: any HTTPRequestInterface,
    decode: @escaping (Data) async throws -> T
  ) async throws -> Result<T, HTTPClientError> {
    let urlRequest = try await request.asUrlRequest(withBaseURL: baseURL)
    let (data, response) = try await execute(urlRequest)
    try validate(response: response, data: data)
    let decodedData = try await decode(data)
    return .success(decodedData)
  }
  
  private func execute(_ request: URLRequest) async throws -> (Data, URLResponse) {
    try await session.data(for: request)
  }
  
  // MARK: - Decoding Response
  
  private func decode<T: Decodable>(_ data: Data) async throws -> T {
    try decoder.decode(T.self, from: data)
  }
  
  // MARK: - Response Validation
  
  private func validate(response: URLResponse, data: Data) throws {
    guard let httpResponse = response as? HTTPURLResponse else { return }
    if !(200..<300).contains(httpResponse.statusCode) {
      throw HTTPClientError.unsuccessfulStatusCode(
        code: httpResponse.statusCode,
        data: data
      )
    }
  }
}

// MARK: - Request

public extension JSONHTTPClient {
  struct JSONRequest: HTTPRequestInterface {
    public typealias MethodType = Method
    
    private let encoder = JSONEncoder()

    public var method: Method
    public var endpoint: String
    public var body: Encodable?
    
    public enum Method: String {
      case get = "GET"
      case post = "POST"
    }
    
    public init(method: Method, endpoint: String, body: Encodable? = nil) {
      self.method = method
      self.endpoint = endpoint
      self.body = body
    }
    
    public func asUrlRequest(withBaseURL baseURL: URL) async throws -> URLRequest {
      guard let url = URL(string: baseURL.absoluteString + endpoint) else {
        throw HTTPClientError.urlEndpointBuildingFailed
      }
      
      var urlRequest = URLRequest(url: url)
      urlRequest.httpMethod = self.method.rawValue
      
      if let body = self.body {
        do {
          urlRequest.httpBody = try encoder.encode(body)
        } catch {
          throw HTTPClientError.encodingUrlRequestBodyFailed(with: error)
        }
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
      }
      urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
      return urlRequest
    }

  }
}
