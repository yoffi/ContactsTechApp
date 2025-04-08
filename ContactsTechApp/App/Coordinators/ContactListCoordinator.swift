//
//  ContactListCoordinator.swift
//  ContactsTechApp
//
//  Created by Joffrey Bocquet on 04/04/2025.
//

import UIKit

@MainActor
final class ContactListCoordinator: ContactListActions, Coordinator {
  var childCoordinators: [any Coordinator] = []
  
  private weak var navigationController: UINavigationController?
  private var client: (any HTTPClientInterface)
  
  init(navigationController: UINavigationController, client: HTTPClientInterface) {
    self.navigationController = navigationController
    self.client = client
  }
  
  func showContactDetails(for id: String) {
    let coordinator: ContactDetailCoordinator = ContactDetailCoordinator(navigationController: navigationController)
    childCoordinators.append(coordinator)
    let viewController = ContactDetailFactory.makeViewController(id: id, client: client, coordinator: coordinator)
    navigationController?.pushViewController(viewController, animated: true)
  }
}
