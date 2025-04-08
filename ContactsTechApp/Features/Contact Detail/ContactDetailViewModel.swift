//
//  ContactDetailViewModel.swift
//  ContactsTechApp
//
//  Created by Joffrey Bocquet on 04/04/2025.
//

import Foundation

struct ContactDetailViewItem {
  let fullname: String
}

final class ContactDetailViewModel: Sendable {
  private let randomUserService: RandomUserServiceInterface
  private let userID: String

  init(randomUserService: RandomUserServiceInterface, userID: String) {
    self.randomUserService = randomUserService
    self.userID = userID
  }
  
  func loadDetails() async -> (any UserInterface)? {
    do {
      let user = try await randomUserService.fetchUser(id: userID)
      return user
    } catch {
      print(error.localizedDescription)
      return nil
    }
  }
}
