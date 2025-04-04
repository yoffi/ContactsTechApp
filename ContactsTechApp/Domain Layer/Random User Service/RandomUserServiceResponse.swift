//
//  UserModel.swift
//  ContactsTechApp
//
//  Created by Joffrey Bocquet on 03/04/2025.
//

import Foundation

extension RandomUserService {

  // MARK: - Response
  
  struct Response: Decodable {
    let results: [User]
    let info: Info
  }
  
  // MARK: - Info
  
  struct Info: Decodable {
    let seed: String
    let results: Int
    let page: Int
    let version: String
  }
  
  struct User: Decodable, UserInterface {
    let gender: String
    let name: Name
    let location: Location
    let email: String
    let login: Login
    let dob: Anniversary
    let registered: Anniversary
    let phone: String
    let cell: String
    let id: ID
    let picture: Picture
    let nat: String
  }
  
  struct Name: Decodable, NameInterface {
    let title: String
    let first: String
    let last: String
  }

  struct ID: Decodable, IDInterface {
    let name: String
    let value: String?
  }
  
  struct Location: Decodable, LocationInterface {
    let street: Street
    let city: String
    let state: String
    let country: String
    let postcode: String
    let coordinates: Coordinates
    let timezone: Timezone
    
    private enum CodingKeys: String, CodingKey {
      case street, city, state, country, postcode, coordinates, timezone
    }
    
    init(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)
      
      street = try container.decode(Street.self, forKey: .street)
      city = try container.decode(String.self, forKey: .city)
      state = try container.decode(String.self, forKey: .state)
      country = try container.decode(String.self, forKey: .country)
      coordinates = try container.decode(Coordinates.self, forKey: .coordinates)
      timezone = try container.decode(Timezone.self, forKey: .timezone)
      
      // Handle postcode which can be Int or String
      if let intPostcode = try? container.decode(Int.self, forKey: .postcode) {
        postcode = String(intPostcode)
      } else if let stringPostcode = try? container.decode(String.self, forKey: .postcode) {
        postcode = stringPostcode
      } else {
        throw DecodingError.dataCorruptedError(forKey: .postcode, in: container, debugDescription: "Postcode is neither Int nor String")
      }
    }
  }
    
  enum Postcode: Decodable {
    case integer(Int)
    case string(String)
    
    var stringValue: String {
      switch self {
        case .integer(let int):
          return String(int)
        case .string(let string):
          return string
      }
    }
  }
  
  // MARK: - Coordinates
  
  struct Coordinates: Decodable, CoordinatesInterface {
    let latitude: String
    let longitude: String
    
    // Computed properties to get double values if needed
    var latitudeValue: Double? {
      return Double(latitude)
    }
    
    var longitudeValue: Double? {
      return Double(longitude)
    }
  }
  
  // MARK: - Street
  
  struct Street: Decodable, StreetInterface {
    let number: Int
    let name: String
  }
  
  // MARK: - Timezone
  
  struct Timezone: Decodable, TimezoneInterface {
    let offset: String
    let description: String
  }
  
  // MARK: - Login
  
  struct Login: Decodable, LoginInterface {
    let uuid: String
    let username: String
    let password: String
    let salt: String
    let md5: String
    let sha1: String
    let sha256: String
  }
  
  // MARK: - Picture
  
  struct Picture: Decodable, PictureInterface {
    let large: URL
    let medium: URL
    let thumbnail: URL
    
    private enum CodingKeys: String, CodingKey {
      case large, medium, thumbnail
    }
    
    init(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)
      
      let largeString = try container.decode(String.self, forKey: .large)
      guard let largeURL = URL(string: largeString) else {
        throw DecodingError.dataCorruptedError(forKey: .large, in: container, debugDescription: "Invalid URL string")
      }
      
      let mediumString = try container.decode(String.self, forKey: .medium)
      guard let mediumURL = URL(string: mediumString) else {
        throw DecodingError.dataCorruptedError(forKey: .medium, in: container, debugDescription: "Invalid URL string")
      }
      
      let thumbnailString = try container.decode(String.self, forKey: .thumbnail)
      guard let thumbnailURL = URL(string: thumbnailString) else {
        throw DecodingError.dataCorruptedError(forKey: .thumbnail, in: container, debugDescription: "Invalid URL string")
      }
      
      large = largeURL
      medium = mediumURL
      thumbnail = thumbnailURL
    }
  }
  
  // MARK: - Registered
  

  struct Anniversary: Decodable, AnniversaryInterface {
    let date: Date
    let age: Int
    
    private enum CodingKeys: String, CodingKey {
      case date, age
    }
    
    private static let ServerDateFormatter: ISO8601DateFormatter = {
      let dateFormatter = ISO8601DateFormatter()
      dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
      return dateFormatter
    }()
    
    init(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)
      age = try container.decode(Int.self, forKey: .age)
      
      let dateString = try container.decode(String.self, forKey: .date)
      let dateFormatter = Anniversary.ServerDateFormatter
      if let date = dateFormatter.date(from: dateString) {
        self.date = date
      } else {
        throw DecodingError.dataCorruptedError(forKey: .date, in: container, debugDescription: "Date format is not valid")
      }
    }
  }
}
