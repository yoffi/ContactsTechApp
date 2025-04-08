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
final class ContactListViewModel: Sendable {
  
  @ObservationIgnored private let randomUserService: RandomUserServiceInterface
  @MainActor private(set) var contacts: [ContactViewModel] = []
  @ObservationIgnored private let pager = Pager()
  actor Pager: Sendable {
    private(set) var page: Int = 0
    
    func next() -> Int {
      page = page + 1
      return page
    }
    
    func reset() -> Int{
      page = 1
      return page
    }
  }
  
  init(randomUserService: RandomUserServiceInterface) {
    self.randomUserService = randomUserService
  }
  
  func loadContacts(with maxResultsPerPage: Int) async  {
    do {
      let users = try await randomUserService.fetchUsers(page: pager.next())
      await MainActor.run {
        contacts = contacts + users.asContactsViewModel
      }
    } catch {
      print(error.localizedDescription)
    }
  }
  
  func reloadContacts(with maxResultsPerPage: Int) async {
    do {
      let users = try await randomUserService.fetchUsers(page: pager.reset())
      await MainActor.run {
        contacts = users.asContactsViewModel
      }
    } catch {
      print(error.localizedDescription)
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
