//
//  PersonNameFormatter+Formatters.swift
//  ContactsTechApp
//
//  Created by Joffrey Bocquet on 07/04/2025.
//

import Foundation

extension PersonNameComponentsFormatter {
  static let longStyle: PersonNameComponentsFormatter = {
    let nameFormatter = PersonNameComponentsFormatter()
    nameFormatter.style = .long
    return nameFormatter
  }()
  
  func fullNameFormatted(with title: String, first: String, last: String) -> String {
    self.string(from: PersonNameComponents(
      namePrefix: title,
      givenName: first,
      familyName:last)
    )
  }
  
  func shortNameFormatted(with first: String, last: String) -> String {
    self.string(from: PersonNameComponents(
      givenName: first,
      familyName:last)
    )
  }
}
