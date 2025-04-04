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

  init(randomUserService: RandomUserServiceInterface) {
    self.randomUserService = randomUserService
  }
  
  func loadDetail() async -> ContactDetailViewItem {
    return ContactDetailViewItem(fullname: "todo")
  }
}
