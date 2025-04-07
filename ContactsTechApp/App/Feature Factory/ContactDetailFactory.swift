//
//  ContactDetailFactory.swift
//  ContactsTechApp
//
//  Created by Joffrey Bocquet on 04/04/2025.
//

import UIKit

class ContactDetailFactory {
  static func makeViewController(id: String, client: HTTPClientInterface, coordinator: Coordinator) -> UIViewController {
    let viewController = ContactDetailViewController(
      coordinator: coordinator,
      viewModel: ContactDetailViewModel(randomUserService: RandomUserService(apiClient: client), userID: id))
    return viewController
  }
}
