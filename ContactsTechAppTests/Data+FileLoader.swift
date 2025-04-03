//
//  Bundle+Utils.swift
//  ContactsTechApp
//
//  Created by Joffrey Bocquet on 03/04/2025.
//

import Foundation

class DumbClass { }

extension Data {
  static func from(filename: String, type: String? = "json") throws -> Data {
    let bundle = Bundle(for: DumbClass.self)
    guard let path = bundle.path(forResource: filename, ofType: type) else {
      throw NSError(domain: "Invalid file name", code: 0, userInfo: nil)
    }
    return try Data(contentsOf: URL(fileURLWithPath: path))
  }
}
