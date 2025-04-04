//
//  ContactDetailFactory.swift
//  ContactsTechApp
//
//  Created by Joffrey Bocquet on 04/04/2025.
//

import UIKit

class ContactDetailFactory {
  static func makeViewController(id: String, coordinator: Coordinator) -> UIViewController {
    let viewController = ContactDetailViewController(coordinator: coordinator)
    return viewController
  }
}
