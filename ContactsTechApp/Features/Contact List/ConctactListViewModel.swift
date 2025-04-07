//
//  ConctactListViewModel.swift
//  ContactsTechApp
//
//  Created by Joffrey Bocquet on 04/04/2025.
//

import Foundation
import Observation

struct ContactViewModel {
  let id: String
  let firstname: String
  let lastname: String
  let memberSince: Date
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
      print(error.localizedDescription)
    }
  }
  
  func handleNewUserResponse(users: [any UserInterface]) async {
    let newContacts = users.asContactsViewModel
    await MainActor.run {
      self.contacts = self.contacts + newContacts
    }
  }
  
  func reloadContacts() async {
    do {
      let users = try await randomUserService.fetchUsers()
      await reloadContactsWith(users: users)
    } catch {
      print(error.localizedDescription)
    }
  }
  
  func reloadContactsWith(users: [any UserInterface]) async {
    let newContacts = users.asContactsViewModel
    await MainActor.run {
      self.contacts = newContacts
    }
  }

  @MainActor
  func willDisplayRow(at index: Int) {
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
        id: $0.login.uuid,
        firstname: $0.name.first,
        lastname: $0.name.last,
        memberSince: $0.registered.date,
        country: $0.nat,
        thumnaillUrl: $0.picture.medium
      )
    }
  }
}
