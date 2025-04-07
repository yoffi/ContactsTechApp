//
//  Date+Formatter.swift
//  ContactsTechApp
//
//  Created by Joffrey Bocquet on 04/04/2025.
//

import Foundation

extension DateFormatter {
  static let RelativeDateFormatter: RelativeDateTimeFormatter = {
    let formatter = RelativeDateTimeFormatter()
    formatter.unitsStyle = .abbreviated
    return formatter
  }()
    
  static let BirthdayDataFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .long
    dateFormatter.timeStyle = .none
    dateFormatter.locale = Locale.current
    return dateFormatter
  }()

  static let EventDataFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .long
    dateFormatter.timeStyle = .medium
    dateFormatter.locale = Locale.current
    return dateFormatter
  }()
}
