//
//  ContactDetailFactory.swift
//  ContactsTechApp
//
//  Created by Joffrey Bocquet on 04/04/2025.
//

import UIKit

@MainActor
class ContactDetailFactory {
  static func makeViewController(id: String, client: HTTPClientInterface, coordinator: Coordinator) -> UIViewController {
    let randomUserService = RandomUserService(apiClient: client)
    let viewModel = ContactDetailViewModel(randomUserService: randomUserService, userID: id)
    let viewController = ContactDetailViewController(coordinator: coordinator, viewModel: viewModel)
    return viewController
  }
}
