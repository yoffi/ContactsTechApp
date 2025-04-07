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
  private var tasks = Set<Task<Void, Never>>()
  
  enum Section {
    case main
  }
  
  private let maxResultsPerPage: Int = 10
  
  private var dataSource: UITableViewDiffableDataSource<Section, ContactViewItem>!
  

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
  
  private lazy var  activityIndicator: UIActivityIndicatorView = {
    let activityIndicator = UIActivityIndicatorView(style: .medium)
    activityIndicator.color = .accent
    activityIndicator.hidesWhenStopped = true
    return activityIndicator
  }()

  
  private func setupUI() {
    title = "Contacts"
    view.backgroundColor = .systemBackground
    
    let barButtonItem = UIBarButtonItem(customView: activityIndicator)
    navigationItem.trailingItemGroups = [.init(barButtonItems: [barButtonItem], representativeItem: nil)]
    
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
    tasks.forEach { $0.cancel() }
  }
  
  // MARK: - Life cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupUI()
    setupTableViewDataSource()
    
    registerForViewModelChanges()
    activityIndicator.startAnimating()
    let loadTask = Task {
      await viewModel.loadContacts(with: maxResultsPerPage)
      activityIndicator.stopAnimating()
    }
    tasks.insert(loadTask)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    if let selectedIndexPath = tableView.indexPathForSelectedRow {
      tableView.deselectRow(at: selectedIndexPath, animated: true)
    }
  }

// MARK: - View model changes observation
  
  private func registerForViewModelChanges() {
    _ = withObservationTracking {
      viewModel.contacts
    } onChange: {
      Task {
        await self.populateDataSource(items: self.viewModel.contacts)
        await self.registerForViewModelChanges()
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
  
  func cellProviderFor(tableView: UITableView, indexPath: IndexPath, item: ContactViewItem) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(
      withIdentifier: ConctacTableViewCell.identifier,
      for: indexPath) as? ConctacTableViewCell  else {
      return UITableViewCell()
    }
    
    cell.configure(with: item)
    
    return cell
  }
  
  private func populateDataSource(items: [ContactViewModel]) {
    var snapshot = NSDiffableDataSourceSnapshot<Section, ContactViewItem>()
    snapshot.appendSections( [.main])
    let itemIdentifiers = items.map(\.self).compactMap(\.asContactViewItem)
    snapshot.appendItems(itemIdentifiers)
    
    if items.count <= maxResultsPerPage {
      dataSource.applySnapshotUsingReloadData(snapshot)
    } else {
      dataSource.apply(snapshot, animatingDifferences: true)
    }
  }
  
  private func loadNextPageIfLastCellBeingDisplayAt(indexPath: IndexPath) {
    let lastContactIndex = max(0, viewModel.contacts.count - 1)
    if indexPath.row == lastContactIndex {
      tasks.insert(Task {
        await viewModel.loadContacts(with: maxResultsPerPage)
      })
    }

  }
}

// MARK: - Tableview Delegate

extension ContactListViewController: UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    loadNextPageIfLastCellBeingDisplayAt(indexPath: indexPath)
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if let item = dataSource.itemIdentifier(for: indexPath) {
      cooridnator?.showContactDetails(for: item.id)
    }
  }
}

// MARK: - Action

extension ContactListViewController {
  @objc func userDidPullToRefresh() {
    Task {
      await viewModel.reloadContacts(with: maxResultsPerPage)
      tableView.refreshControl?.endRefreshing()
    }
  }
}

// MARK: - Convert

extension ContactViewModel {
  var asContactViewItem: ContactViewItem {
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
