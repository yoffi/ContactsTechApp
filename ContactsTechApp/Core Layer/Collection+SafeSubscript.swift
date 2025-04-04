//
//  Collection+SafeSubscript.swift
//  ContactsTechApp
//
//  Created by Joffrey Bocquet on 04/04/2025.
//

extension Collection {
  subscript(safe index: Index) -> Element? {
    return indices.contains(index) ? self[index] : nil
  }
}
