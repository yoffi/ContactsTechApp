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

class ContactDetailViewModel {
  private var randomUserService: RandomUserServiceInterface
  private var userID: String

  init(randomUserService: RandomUserServiceInterface, userID: String) {
    self.randomUserService = randomUserService
    self.userID = userID
  }
  
  func loadDetails() async -> (any UserInterface)? {
    do {
      let user = try await randomUserService.fetchUsers()
      return user.first!
    } catch {
      print(error.localizedDescription)
      return nil
    }
  }
}
