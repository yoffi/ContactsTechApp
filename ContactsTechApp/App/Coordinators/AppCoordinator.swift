//
//  AppCoordinator.swift
//  ContactsTechApp
//
//  Created by Joffrey Bocquet on 04/04/2025.
//

import UIKit

@MainActor
protocol Coordinator: AnyObject {
  var childCoordinators: [Coordinator] { get set }
  func finish(_ child: (any Coordinator)?)
}

@MainActor
final class AppCoordinator: NSObject, Coordinator {
  var childCoordinators: [Coordinator] = []
  var parentCoordinator: (any Coordinator)? = nil
  
  private var navigationController: UINavigationController = UINavigationController()
  
  private static var session: URLSession = {
    let cache = URLCache(
      memoryCapacity: 50 * 1024 * 1024,  // 50MB in memory
      diskCapacity: 200 * 1024 * 1024  // 200MB on disk
    )
    
    let configuration = URLSessionConfiguration.default
    configuration.waitsForConnectivity = false
    configuration.requestCachePolicy = .returnCacheDataElseLoad
    configuration.urlCache = cache
    
    return URLSession(configuration: configuration)
  }()
  
  private static var httpClient: JSONHTTPClient = {
    return try! JSONHTTPClient(
      session: AppCoordinator.session,
      baseURL: "http://randomuser.me"
    )
  }()
  
  func mainViewController() -> UIViewController {
    navigationController.viewControllers = [contactListViewController()]
    return navigationController
  }
  
  func contactListViewController() -> UIViewController {
    let contactListCoordinator = ContactListCoordinator(
      navigationController: navigationController,
      client: AppCoordinator.httpClient)
    childCoordinators.append(contactListCoordinator)
    
    let controller = ContactListFactory.makeViewController(
      client: AppCoordinator.httpClient,
      coordinator: contactListCoordinator
    )
    return controller
  }
}

extension AppCoordinator: UINavigationControllerDelegate {
  func navigationController(
    _ navigationController: UINavigationController,
    didShow viewController: UIViewController,
    animated: Bool
  ) {
    //manage our reference to child coordinator here and remove them from memory if the nav pop out
    guard let fromViewController = navigationController.transitionCoordinator?.viewController(forKey: .from),
      !navigationController.viewControllers.contains(fromViewController) else {
      return
    }
    
    if let contactDetailViewController = fromViewController as? ContactDetailViewController {
      finish(contactDetailViewController.coordinator)
    }
  }
}

extension Coordinator {
  func finish(_ child: (any Coordinator)?) {
    for (index, coordinator) in childCoordinators.enumerated() {
      if coordinator === child {
        childCoordinators.remove(at: index)
        break
      }
    }
  }
}
