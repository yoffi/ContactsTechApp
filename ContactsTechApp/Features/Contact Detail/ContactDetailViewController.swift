//
//  ContactDetailViewController.swift
//  ContactsTechApp
//
//  Created by Joffrey Bocquet on 04/04/2025.
//

import UIKit

struct ContactDetailViewItem {
  let fullname: String
  let pictureURL: URL
  let sections: [ContactDetailSecionViewItem]
}

struct ContactDetailSecionViewItem {
  let title: String
  let systemName: String
  let rows: [ContactDetailSectionRowViewItem]
}

struct ContactDetailSectionRowViewItem {
  let label: String
  let value: String
}


class ContactDetailViewController: UIViewController {
  
  private(set) weak var coordinator: Coordinator?
  private var viewModel: ContactDetailViewModel
  private var userViewModelItem: ContactDetailViewItem!
  private var loadTask: Task<Void, Never>?
  private var loadImageTask: Task<Void, Never>?
  private let scrollView = UIScrollView()
  private let contentView = UIView()
  
  // MARK: - Init
  
  init(coordinator: Coordinator, viewModel: ContactDetailViewModel) {
    self.coordinator = coordinator
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  deinit {
    loadTask?.cancel()
    loadImageTask?.cancel()
  }
  
// MARK: - Life cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .systemBackground
    title = "Contact Detail"
    navigationController?.navigationBar.prefersLargeTitles = false
    setupUI()
    loadTask = Task { @MainActor in
      if let user = await viewModel.loadDetails() {
        self.userViewModelItem = user.asContactViewItem
        configureUI()
      }
    }
  }
  // MARK: - UI Components
  
  private let userImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFill
    imageView.clipsToBounds = true
    imageView.layer.cornerRadius = 16
    imageView.backgroundColor = .systemGray6
    imageView.translatesAutoresizingMaskIntoConstraints = false
    return imageView
  }()
  
  private let userNameLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
    label.textAlignment = .center
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()
  
  private let detailStackView: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.spacing = 16
    stackView.alignment = .fill
    stackView.distribution = .fill
    stackView.translatesAutoresizingMaskIntoConstraints = false
    return stackView
  }()
  
  
  // MARK: - UI Setup
  private func setupUI() {
    view.backgroundColor = .systemBackground
    
    // Setup scroll view
    scrollView.translatesAutoresizingMaskIntoConstraints = false
    contentView.translatesAutoresizingMaskIntoConstraints = false
    
    view.addSubview(scrollView)
    scrollView.addSubview(contentView)
    
    NSLayoutConstraint.activate([
      scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      
      contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
      contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
      contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
      contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
      contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
    ])
    
    // Add main components to contentView
    contentView.addSubview(userImageView)
    contentView.addSubview(userNameLabel)
    contentView.addSubview(detailStackView)
    
    NSLayoutConstraint.activate([
      // Profile image centered at top
      userImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
      userImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
      userImageView.widthAnchor.constraint(equalToConstant: 100),
      userImageView.heightAnchor.constraint(equalToConstant: 100),
      
      // Name label below image
      userNameLabel.topAnchor.constraint(equalTo: userImageView.bottomAnchor, constant: 16),
      userNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
      userNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
      
      // Stack view with all details
      detailStackView.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor, constant: 24),
      detailStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
      detailStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
      detailStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24)
    ])
  }
  
  private func configureUI() {
    
    // Load user image
    loadImageTask = Task {
      await userImageView.loadImage(from: userViewModelItem.pictureURL)
    }
    
    userNameLabel.text = userViewModelItem.fullname
    
    for section in userViewModelItem.sections {
      let sectionView =  createSectionView(title: section.title, iconName: section.systemName)
      for row in section.rows {
        addDetailRow(to: sectionView, title: row.label, value: row.value)
      }
      detailStackView.addArrangedSubview(sectionView)
    }
  }
  
  
  // MARK: - Helper Methods
  
  private func createSectionView(title: String, iconName: String = "info.circle") -> UIView {
    let sectionView = UIView()
    sectionView.translatesAutoresizingMaskIntoConstraints = false
    
    // Create header stack to hold icon and title
    let headerStack = UIStackView()
    headerStack.axis = .horizontal
    headerStack.spacing = 10
    headerStack.alignment = .center
    headerStack.translatesAutoresizingMaskIntoConstraints = false
    
    // Create icon image view with SF Symbol
    let iconView = UIImageView()
    iconView.translatesAutoresizingMaskIntoConstraints = false
    iconView.contentMode = .scaleAspectFit
    iconView.tintColor = .accent
    iconView.image = UIImage(systemName: iconName)
    
    // Size constraints for icon
    NSLayoutConstraint.activate([
      iconView.widthAnchor.constraint(equalToConstant: 28),
      iconView.heightAnchor.constraint(equalToConstant: 28)
    ])
    
    let titleLabel = UILabel()
    titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
    titleLabel.text = title
    titleLabel.textColor = .secondaryLabel
    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    
    // Add icon and title to header stack
    headerStack.addArrangedSubview(iconView)
    headerStack.addArrangedSubview(titleLabel)
    
    let separator = UIView()
    separator.backgroundColor = .secondarySystemBackground
    separator.translatesAutoresizingMaskIntoConstraints = false
    
    let detailsStack = UIStackView()
    detailsStack.axis = .vertical
    detailsStack.spacing = 12
    detailsStack.alignment = .fill
    detailsStack.distribution = .fill
    detailsStack.translatesAutoresizingMaskIntoConstraints = false
    
    sectionView.addSubview(headerStack)
    sectionView.addSubview(separator)
    sectionView.addSubview(detailsStack)
    
    NSLayoutConstraint.activate([
      headerStack.topAnchor.constraint(equalTo: sectionView.topAnchor, constant: 16),
      headerStack.leadingAnchor.constraint(equalTo: sectionView.leadingAnchor),
      headerStack.trailingAnchor.constraint(equalTo: sectionView.trailingAnchor),
      
      separator.topAnchor.constraint(equalTo: headerStack.bottomAnchor, constant: 8),
      separator.leadingAnchor.constraint(equalTo: sectionView.leadingAnchor),
      separator.trailingAnchor.constraint(equalTo: sectionView.trailingAnchor),
      separator.heightAnchor.constraint(equalToConstant: 1),
      
      detailsStack.topAnchor.constraint(equalTo: separator.bottomAnchor, constant: 16),
      detailsStack.leadingAnchor.constraint(equalTo: sectionView.leadingAnchor),
      detailsStack.trailingAnchor.constraint(equalTo: sectionView.trailingAnchor),
      detailsStack.bottomAnchor.constraint(equalTo: sectionView.bottomAnchor, constant: -16)
    ])
    
    detailsStack.tag = 100
    
    return sectionView
  }
  
  private func addDetailRow(to sectionView: UIView, title: String, value: String) {
    guard let detailsStack = sectionView.viewWithTag(100) as? UIStackView else { return }
    
    let rowStack = UIStackView()
    rowStack.axis = .horizontal
    rowStack.spacing = 16
    rowStack.alignment = .top
    rowStack.distribution = .fill
    rowStack.translatesAutoresizingMaskIntoConstraints = false
    
    let titleLabel = UILabel()
    titleLabel.font = .preferredFont(forTextStyle: .subheadline)
    titleLabel.text = title
    titleLabel.textColor = .secondaryLabel
    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    titleLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    titleLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
    
    let valueLabel = UILabel()
    valueLabel.font = .preferredFont(forTextStyle: .body)
    valueLabel.text = value
    valueLabel.textColor = .label
    valueLabel.numberOfLines = 0
    valueLabel.translatesAutoresizingMaskIntoConstraints = false
    
    
    rowStack.addArrangedSubview(titleLabel)
    rowStack.addArrangedSubview(valueLabel)
    
    NSLayoutConstraint.activate([
      titleLabel.widthAnchor.constraint(equalToConstant: 120)
    ])
    
    detailsStack.addArrangedSubview(rowStack)
  }
  

  // MARK: - Actions
  
  @objc private func emailTapped(_ gesture: UITapGestureRecognizer) {
    guard let label = gesture.view as? UILabel, let email = label.text else { return }
    
    if let url = URL(string: "mailto:\(email)") {
      UIApplication.shared.open(url)
    }
  }
  
  @objc private func phoneTapped(_ gesture: UITapGestureRecognizer) {
    guard let label = gesture.view as? UILabel, let phone = label.text else { return }
    
    // Remove any non-numeric characters for dialing
    let numericPhone = phone.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
    
    if let url = URL(string: "tel:\(numericPhone)") {
      UIApplication.shared.open(url)
    }
  }
}

// MARK: - Converts

extension ContactDetailViewModelItem {
  var asContactViewItem: ContactDetailViewItem {
    return ContactDetailViewItem(
      fullname: self.fullname,
      pictureURL: self.pictureURL,
      sections: self.sections.map { section in
        ContactDetailSecionViewItem(
          title: section.title,
          systemName: section.systemName,
          rows: section.rows.map { row in
            ContactDetailSectionRowViewItem(
              label: row.label,
              value: row.value
            )
          }
        )
      }
    )
  }
}
