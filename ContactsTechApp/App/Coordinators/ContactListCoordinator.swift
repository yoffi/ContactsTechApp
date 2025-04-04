//
//  ContactListCoordinator.swift
//  ContactsTechApp
//
//  Created by Joffrey Bocquet on 04/04/2025.
//

import UIKit

class ContactListCoordinator: ContactListActions, Coordinator {
  var childCoordinators: [any Coordinator] = []
  
  private weak var navigationController: UINavigationController?
  
  init(navigationController: UINavigationController) {
    self.navigationController = navigationController
  }
  
  func showContactDetails(for id: String) {
    let coordinator: ContactDetailCoordinator = ContactDetailCoordinator(navigationController: navigationController)
    childCoordinators.append(coordinator)
    let viewController = ContactDetailFactory.makeViewController(id: id, coordinator: coordinator)
    navigationController?.pushViewController(viewController, animated: true)
  }
}
