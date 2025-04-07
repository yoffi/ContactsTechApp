//
//  RandomUserServiceInterface.swift
//  ContactsTechApp
//
//  Created by Joffrey Bocquet on 03/04/2025.
//

import Foundation

protocol RandomUserServiceInterface {
  func fetchUsers() async throws -> [any UserInterface]
}

protocol UserInterface {
  associatedtype NameType: NameInterface
  associatedtype LocationType: LocationInterface
  associatedtype LoginType: LoginInterface
  associatedtype AnniversaryType: AnniversaryInterface
  associatedtype IDType: IDInterface
  associatedtype PictureType: PictureInterface
  
  var gender: String { get }
  var name: NameType { get }
  var location: LocationType { get }
  var email: String { get }
  var login: LoginType { get }
  var dob: AnniversaryType { get }
  var registered: AnniversaryType { get }
  var phone: String { get }
  var cell: String { get }
  var id: IDType { get }
  var picture: PictureType { get }
  var nat: String { get }
}

protocol NameInterface {
  var title: String { get }
  var first: String { get }
  var last: String { get }
}

protocol LocationInterface {
  associatedtype StreetType: StreetInterface
  associatedtype CoordinatesType: CoordinatesInterface
  associatedtype TimeZoneType: TimezoneInterface
  
  var street: StreetType { get }
  var city: String { get }
  var state: String { get }
  var country: String { get }
  var postcode: String { get }
  var coordinates: CoordinatesType { get }
  var timezone: TimeZoneType { get }
}

protocol StreetInterface {
  var number: Int { get }
  var name: String { get }
}

protocol CoordinatesInterface {
  var latitude: Double { get }
  var longitude: Double { get }
}

protocol TimezoneInterface {
  var offset: String { get }
  var description: String { get }
}

protocol LoginInterface {
  var uuid: String { get }
  var username: String { get }
  var password: String { get }
  var salt: String { get }
  var md5: String { get }
  var sha1: String { get }
  var sha256: String { get }
}

protocol AnniversaryInterface {
  var date: Date { get }
  var age: Int { get }
}

protocol IDInterface {
  var name: String { get }
  var value: String? { get }
}

protocol PictureInterface {
  var large: URL { get }
  var medium: URL { get }
  var thumbnail: URL { get }
}
