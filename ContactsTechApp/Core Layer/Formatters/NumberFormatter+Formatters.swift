//
//  NumberFormatter+Formatters.swift
//  ContactsTechApp
//
//  Created by Joffrey Bocquet on 07/04/2025.
//

import Foundation

extension NumberFormatter {
  static let CoordinateFromatter: NumberFormatter = {
      let numberFormatter = NumberFormatter()
      numberFormatter.numberStyle = .decimal
      numberFormatter.maximumFractionDigits = 6
      numberFormatter.locale = Locale.current
    return numberFormatter
  }()
  
  func string(latitude: Double, longitude: Double) -> String {
    let latFormatted = string(from: NSNumber(value: latitude)) ?? "\(latitude)"
    let longFormatted = string(from: NSNumber(value: longitude)) ?? "\(longitude)"
    return "\(latFormatted), \(longFormatted)"
  }
  
  static let PhoneFormatter:  NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.locale = Locale.current
    return formatter
  }()
  
  func string(from phone: String) -> String {
    // This is a simple implementation
    // formating Phone number can be complex to do, we could replace this by usning external library
    return phone
  }
  
}
