//
//  Date+Formatter.swift
//  ContactsTechApp
//
//  Created by Joffrey Bocquet on 04/04/2025.
//

import Foundation

extension Date {
  static let relativeDateFormatter: RelativeDateTimeFormatter = {
    let formatter = RelativeDateTimeFormatter()
    formatter.unitsStyle = .abbreviated
    return formatter
  }()
  
  func relativeDate(from: Date = .now) -> String {
    return Date.relativeDateFormatter.localizedString(for: self, relativeTo: from)
  }
}
