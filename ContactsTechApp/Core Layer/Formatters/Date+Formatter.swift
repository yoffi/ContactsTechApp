//
//  Date+Formatter.swift
//  ContactsTechApp
//
//  Created by Joffrey Bocquet on 04/04/2025.
//

import Foundation

extension DateFormatter {
  static let relativeFormatStyle: Date.RelativeFormatStyle = {
    Date.RelativeFormatStyle(
      presentation: .named,
      unitsStyle: .abbreviated
    )
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

  static let ServerDateStyle: Date.ISO8601FormatStyle = {
    Date.ISO8601FormatStyle(
      dateSeparator: .dash,
      dateTimeSeparator: .standard,
      timeSeparator: .colon,
      timeZoneSeparator: .omitted,
      includingFractionalSeconds: true)
  }()
}

extension DateComponentsFormatter {
  static let YearDurationFormatter: DateComponentsFormatter = {
    let formatter = DateComponentsFormatter()
    formatter.allowedUnits = [.year]
    formatter.unitsStyle = .full
    return formatter
  }()
  
  func string(from years: Int) -> String {
    self.string(from: DateComponents(year: years)) ?? "\(years)"
  }
}
