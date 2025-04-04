//
//  ConctactListViewModel.swift
//  ContactsTechApp
//
//  Created by Joffrey Bocquet on 04/04/2025.
//

import Foundation
import Observation

struct ContactViewModel {
  let name: String
  let memberSince: String
  let country: String
  let thumnaillUrl: URL?
}

@Observable
class ContactListViewModel {
  
  private var randomUserService: RandomUserServiceInterface
  
  @MainActor
  private(set) var contacts: [ContactViewModel] = []
  
  init(randomUserService: RandomUserServiceInterface) {
    self.randomUserService = randomUserService
  }
  
  func loadContacts() async  {
    do {
      let users = try await randomUserService.fetchUsers()
      await self.handleNewUserResponse(users: users)
    } catch {
      print(error)
    }
  }
  
  func handleNewUserResponse(users: [any UserInterface]) async {
    let newContacts = users.asContactsViewModel
    await MainActor.run {
      self.contacts = self.contacts + newContacts
    }
  }
  
  @MainActor
  func willDisplayRowa(at index: Int) {
    if index == contacts.count - 1 {
      Task {
        await self.loadContacts()
      }
    }
  }
}

// MARK: - Convert

extension Array where Element == any UserInterface {
  var asContactsViewModel: [ContactViewModel] {
    map {
      .init(
        name: "\($0.name.first) \($0.name.last)",
        memberSince: "member since: \($0.registered.date.relativeDate())",
        country: $0.nat,
        thumnaillUrl: $0.picture.medium
      )
    }
  }
}
