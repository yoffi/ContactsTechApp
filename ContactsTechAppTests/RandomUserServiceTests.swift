//
//  RandomUserServiceTests.swift
//  ContactsTechAppTests
//
//  Created by Joffrey Bocquet on 03/04/2025.
//

import Foundation
import Testing
@testable import ContactsTechApp

@Suite(.serialized)
struct RandomUserServiceTests {
  
  var mockedSession: URLSession = {
    let configuration = URLSessionConfiguration.ephemeral
    configuration.protocolClasses = [MockURLProtocol.self]
    return URLSession(configuration: configuration)
  }()
  
  var sut: RandomUserService
  
  init() async throws {
    let configuration = URLSessionConfiguration.ephemeral
    configuration.protocolClasses = [MockURLProtocol.self]
    
    self.sut = try RandomUserService(
      apiClient: JSONHTTPClient(
        session: mockedSession,
        baseURL: "http://stuburl.com"
      )
    )
  }
  
  @Test func fetchUsers() async throws {
    let mockedJSONData = try Data.from(filename: "RamdomUserStubs", type: "json")
    MockURLProtocol.requestHandler = { request in
      #expect(request.url?.absoluteString == "http://stuburl.com/api/?page=1&results=10&seed=technicaltest")
      let response = HTTPURLResponse(
        url: request.url!,
        statusCode: 200,
        httpVersion: nil,
        headerFields: nil
      )!
      return (response, mockedJSONData)
    }
    
    let result = try await sut.fetchUsers(page: 1)
    
    #expect(result.count == 10)
  }
  
  @Test func fetchUsersWithInvalidJSONData() async throws {
    let mockedJSONData = try Data.from(filename: "RamdomUserInvalidStubs", type: "json")
    MockURLProtocol.requestHandler = { request in
      #expect(request.url?.absoluteString == "http://stuburl.com/api/?page=1&results=10&seed=technicaltest")
      let response = HTTPURLResponse(
        url: request.url!,
        statusCode: 200,
        httpVersion: nil,
        headerFields: nil
      )!
      return (response, mockedJSONData)
    }
    
    async #expect(throws: DecodingError) {
      try await sut.fetchUsers(page: 1)
    }
  }

  @Test(arguments: [500, 501, 502, 503, 504, 505])
  func fetchUsersWhenServerFailed(statusCode: Int) async throws {
    let mockedJSONData = try Data.from(filename: "RamdomUserStubs", type: "json")
    MockURLProtocol.requestHandler = { request in
      #expect(request.url?.absoluteString == "http://stuburl.com/api/?page=1&results=10&seed=technicaltest")
      let response = HTTPURLResponse(
        url: request.url!,
        statusCode: statusCode,
        httpVersion: nil,
        headerFields: nil
      )!
      return (response, mockedJSONData)
    }

    async #expect(throws: HTTPClientError.unsuccessfulStatusCode(code: statusCode, data: nil)) {
      try await sut.fetchUsers(page: 1)
    }
  }

}
