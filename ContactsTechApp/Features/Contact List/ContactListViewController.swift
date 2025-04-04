//
//  ContactListViewController.swift
//  ContactsTechApp
//
//  Created by Joffrey Bocquet on 04/04/2025.
//

import Foundation
import UIKit
import Observation

protocol ContactListActions: AnyObject {
  func showContactDetails(for id: String)
}

class ContactListViewController: UIViewController {
  
  private var viewModel: ContactListViewModel
  private(set) weak var cooridnator: (any ContactListActions)?
  private var loadContactTask: Task<Void, Never>?


  // MARK: - UI Components
  
  private lazy var tableView: UITableView = {
    let tableView = UITableView()
    tableView.register(ConctacTableViewCell.self, forCellReuseIdentifier: ConctacTableViewCell.identifier)
    tableView.delegate = self
    tableView.dataSource = self
    tableView.rowHeight = 70
    tableView.separatorStyle = .singleLine
    tableView.translatesAutoresizingMaskIntoConstraints = false
    return tableView
  }()
  
  private func setupUI() {
    title = "Contacts"
    view.backgroundColor = .systemBackground
    
    // Add subviews
    view.addSubview(tableView)
    
    // Setup constraints
    NSLayoutConstraint.activate([
      tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ])
  }
  
  // MARK: - Init
  
  init(viewModel: ContactListViewModel, coordinator: any ContactListActions) {
    self.viewModel = viewModel
    self.cooridnator = coordinator
    
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  deinit {
    loadContactTask?.cancel()
  }
  
  // MARK: - Life cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupUI()
    
    registerForViewModelChanges()
    loadContactTask = Task {
      await viewModel.loadContacts()
    }
  }

// MARK: - View model changes observation
  
  private func registerForViewModelChanges() {
    _ = withObservationTracking {
      viewModel.contacts
    } onChange: {
      Task { @MainActor in
        self.tableView.reloadData()
        self.registerForViewModelChanges()
      }
    }
  }
}

extension ContactListViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    viewModel.willDisplayRowa(at: indexPath.row)
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    cooridnator?.showContactDetails(for: viewModel.contacts[indexPath.row].name)
  }
}

extension ContactListViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    viewModel.contacts.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: ConctacTableViewCell.identifier, for: indexPath) as? ConctacTableViewCell,
          let contact = viewModel.contacts[safe: indexPath.row] else {
      return UITableViewCell()
    }
  
    cell.configure(with: contact.asContactViewItem)
    
    return cell
  }
}

// MARK: - Convert

extension ContactViewModel {
  var asContactViewItem: ConctactViewItem {
    .init(name: name, subtitle: memberSince, alternativeText: country, avatarImage: thumnaillUrl)
  }
}
