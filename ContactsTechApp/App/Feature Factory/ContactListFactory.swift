//
//  ContactListFactory.swift
//  ContactsTechApp
//
//  Created by Joffrey Bocquet on 03/04/2025.
//

import Foundation
import UIKit

@MainActor
class ContactListFactory {
  static func makeViewController(client: JSONHTTPClient, coordinator: ContactListCoordinator) -> UIViewController {
    
    let randomUserService = RandomUserService(apiClient: client)
    let contactListViewModel = ContactListViewModel(randomUserService: randomUserService)
    
    let contactListViewController = ContactListViewController(viewModel: contactListViewModel, coordinator: coordinator)
    
    return contactListViewController
  }
}
