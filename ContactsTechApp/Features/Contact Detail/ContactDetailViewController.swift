//
//  ContactDetailViewController.swift
//  ContactsTechApp
//
//  Created by Joffrey Bocquet on 04/04/2025.
//

import UIKit

class ContactDetailViewController: UIViewController {
  private(set) var coordinator: Coordinator
  
  // MARK: - Init
  
  init(coordinator: Coordinator) {
    self.coordinator = coordinator
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
// MARK: - Life cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .systemBackground
    title = "Contact Detail"
    navigationItem.largeTitleDisplayMode = .never
  }
}
