//
//  ConctacTableViewCell.swift
//  ContactsTechApp
//
//  Created by Joffrey Bocquet on 04/04/2025.
//

import UIKit

struct ConctactViewItem: Hashable {
  let id: String
  let name: String
  let subtitle: String
  let alternativeText: String
  let avatarImage: URL?
}

// MARK: - Custom TableViewCell

class ConctacTableViewCell: UITableViewCell {
  static let identifier = "ConctacTableViewCell"
  private var imageLoadingTask: Task<Void, Never>?
  
  // MARK: - UI Components
  
  private let avatarImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFill
    imageView.clipsToBounds = true
    imageView.layer.cornerRadius = 16
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.tintColor = .systemBlue
    return imageView
  }()
  
  private let nameLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()
  
  private let subtitleLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont.systemFont(ofSize: 14)
    label.textColor = .gray
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()
  
  private let alternativeLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
    label.textColor = .systemGray
    label.textAlignment = .right
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()
  
  // Stack views for better organization
  private let textStackView: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.spacing = 4
    stackView.translatesAutoresizingMaskIntoConstraints = false
    return stackView
  }()
  
  // MARK: - UI Setup
  
  private func setupUI() {
    // Add subviews
    contentView.addSubview(avatarImageView)
    
    textStackView.addArrangedSubview(nameLabel)
    textStackView.addArrangedSubview(subtitleLabel)
    contentView.addSubview(textStackView)
    
    contentView.addSubview(alternativeLabel)
    
    // Setup constraints
    NSLayoutConstraint.activate([
      // Avatar image constraints
      avatarImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
      avatarImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
      avatarImageView.widthAnchor.constraint(equalToConstant: 50),
      avatarImageView.heightAnchor.constraint(equalToConstant: 50),
      
      // Text stack view constraints
      textStackView.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 12),
      textStackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
      
      // Alternative label constraints
      alternativeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
      alternativeLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
      alternativeLabel.leadingAnchor.constraint(greaterThanOrEqualTo: textStackView.trailingAnchor, constant: 12)
    ])
  }
  // MARK: - Initialization
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setupUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  // MARK: - View Cycle
  
  override func prepareForReuse() {
    super.prepareForReuse()
    nameLabel.text = nil
    subtitleLabel.text = nil
    alternativeLabel.text = nil
    avatarImageView.image = nil
    avatarImageView.image = UIImage(systemName: "person.circle.fill")
    
    imageLoadingTask?.cancel()
    imageLoadingTask = nil
  }
  
  // MARK: - Configure Cell
  
  func configure(with person: ConctactViewItem) {
    nameLabel.text = person.name
    subtitleLabel.text = person.subtitle
    alternativeLabel.text = person.alternativeText
    
    if let imageURL = person.avatarImage {
      loadImage(from: imageURL)
    }
  }
  
  private func loadImage(from url: URL) {
    imageLoadingTask?.cancel()
    
    // Create a new task for loading the image
    imageLoadingTask = Task {
      await avatarImageView.loadImage(from: url)
    }
  }
}
