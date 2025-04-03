//
//  HTTPClientInterface.swift
//  ContactsTechApp
//
//  Created by Joffrey Bocquet on 03/04/2025.
//

import Foundation

public protocol HTTPClientInterface {
  /// The URL session used for networking
  var session: URLSession { get }

  /// Execute a request and return a decodable response
  func execute<T: Decodable>(_ request: any HTTPRequestInterface) async throws -> Result<T, HTTPClientError>
}

// MARK: - HTTP Request Protocol

/// Protocol defining the requirements for an HTTP request
public protocol HTTPRequestInterface {
  /// HTTP method type (GET, POST, etc.)
  associatedtype MethodType
  
  /// The HTTP method to use
  var method: MethodType { get }
  
  /// The endpoint path
  var endpoint: String { get }
  
  /// Optional body to include in the request
  var body: Encodable? { get }
  
  /// Convert the request to a URLRequest with the given base URL
  func asUrlRequest(withBaseURL baseURL: URL) async throws -> URLRequest
}


public enum HTTPClientError: Error, Equatable {
  case baseUrlBuildingFailed
  case urlEndpointBuildingFailed
  case unsuccessfulStatusCode(code: Int, data: Data?)
  case encodingUrlRequestBodyFailed(with: Error)
  
  public static func == (lhs: HTTPClientError, rhs: HTTPClientError) -> Bool {
    switch (lhs, rhs) {
      case (.baseUrlBuildingFailed, .baseUrlBuildingFailed):
        return true
      case (.urlEndpointBuildingFailed, .urlEndpointBuildingFailed):
        return true
      case let (.unsuccessfulStatusCode(lhsCode, lhsData), .unsuccessfulStatusCode(rhsCode, rhsData)):
        return lhsCode == rhsCode && lhsData == rhsData
      case (.encodingUrlRequestBodyFailed, .encodingUrlRequestBodyFailed):
        // Error protocol doesn't conform to Equatable, so we can't compare the underlying errors
        // We consider them equal if they're both this case
        return true
      default:
        return false
    }
  }
}
