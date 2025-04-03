//
//  MockHTTPClient.swift
//  ContactsTechApp
//
//  Created by Joffrey Bocquet on 03/04/2025.
//

import Foundation
import Testing
@testable import ContactsTechApp

class MockURLProtocol: URLProtocol {
  static var error: Error?
  static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?
  
  override class func canInit(with request: URLRequest) -> Bool {
    return true
  }
  
  override class func canonicalRequest(for request: URLRequest) -> URLRequest {
    return request
  }
  
  override func startLoading() {
    if let error = MockURLProtocol.error {
      client?.urlProtocol(self, didFailWithError: error)
      return
    }
    
    guard let handler = MockURLProtocol.requestHandler else {
      assertionFailure("Received unexpected request with no handler set")
      return
    }
    
    do {
      let (response, data) = try handler(request)
      client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
      client?.urlProtocol(self, didLoad: data)
      client?.urlProtocolDidFinishLoading(self)
    } catch {
      client?.urlProtocol(self, didFailWithError: error)
    }
  }
  
  override func stopLoading() {
  }
}

class MockBisURLProtocol: URLProtocol {
  override class func canInit(with request: URLRequest) -> Bool {
    return true
  }
  
  override class func canonicalRequest(for request: URLRequest) -> URLRequest {
    return request
  }
  
  static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?
  
  override func startLoading() {
    guard let handler = MockURLProtocol.requestHandler else {
      assertionFailure("No request handler provided.")
      return
    }
    
    do {
      let (response, data) = try handler(request)
      client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
      client?.urlProtocol(self, didLoad: data)
      client?.urlProtocolDidFinishLoading(self)
    } catch {
      assertionFailure(("Error handling the request: \(error)"))
    }
  }
  
  override func stopLoading() {}
  
}
