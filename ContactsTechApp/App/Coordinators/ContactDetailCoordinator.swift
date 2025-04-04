//
//  ContactDetailCoordinator.swift
//  ContactsTechApp
//
//  Created by Joffrey Bocquet on 04/04/2025.
//

import UIKit

class ContactDetailCoordinator: Coordinator {
  var childCoordinators: [any Coordinator] = []
  
  private weak var navigationController: UINavigationController?
  
  init(navigationController: UINavigationController?) {
    self.navigationController = navigationController
  }
}
