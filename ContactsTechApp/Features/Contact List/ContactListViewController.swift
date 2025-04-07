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
  
  enum Section {
    case main
  }
  
  private var dataSource: UITableViewDiffableDataSource<Section, ConctactViewItem>!


  // MARK: - UI Components
  
  private lazy var tableView: UITableView = {
    let tableView = UITableView()
    tableView.register(ConctacTableViewCell.self, forCellReuseIdentifier: ConctacTableViewCell.identifier)
    tableView.delegate = self
    tableView.rowHeight = 70
    tableView.separatorStyle = .singleLine
    tableView.translatesAutoresizingMaskIntoConstraints = false
    tableView.refreshControl = UIRefreshControl()
    tableView.refreshControl?.addTarget(self, action: #selector(userDidPullToRefresh), for: .valueChanged)
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
    setupTableViewDataSource()
    
    registerForViewModelChanges()
    populateDataSource(items: [])
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
        self.populateDataSource(items: self.viewModel.contacts)
        self.registerForViewModelChanges()
      }
    }
  }
}

// MARK: - TableView DataSource

extension ContactListViewController {
  func setupTableViewDataSource() {
    dataSource = UITableViewDiffableDataSource(
      tableView: tableView,
      cellProvider: cellProviderFor(tableView:indexPath:item:))
  }
  
  func cellProviderFor(tableView: UITableView, indexPath: IndexPath, item: ConctactViewItem) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: ConctacTableViewCell.identifier, for: indexPath) as? ConctacTableViewCell,
          let contact = self.viewModel.contacts[safe: indexPath.row] else {
      return UITableViewCell()
    }
    
    cell.configure(with: contact.asContactViewItem)
    
    return cell
  }
  
  func populateDataSource(items: [ContactViewModel]) {
    var snapshot = NSDiffableDataSourceSnapshot<Section, ConctactViewItem>()
    snapshot.appendSections( [.main])
    snapshot.appendItems(items.map(\.self).compactMap(\.asContactViewItem))
    dataSource.apply(snapshot, animatingDifferences: true)
  }
}


// MARK: - Tableview Delegate

extension ContactListViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    viewModel.willDisplayRow(at: indexPath.row)
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    cooridnator?.showContactDetails(for: viewModel.contacts[indexPath.row].id)
  }
}

// MARK: - Action

extension ContactListViewController {
  @objc func userDidPullToRefresh() {
    loadContactTask = Task {
      await viewModel.reloadContacts()
      await MainActor.run {
        tableView.refreshControl?.endRefreshing()
      }
    }
  }
}

// MARK: - Convert

extension ContactViewModel {
  var asContactViewItem: ConctactViewItem {
    .init(
      id: id,
      firstname: firstname,
      lastname: lastname,
      subtitle: DateFormatter.RelativeDateFormatter.localizedString(for: memberSince, relativeTo: .now),
      alternativeText: country,
      avatarImage: thumnaillUrl
    )
  }
}
