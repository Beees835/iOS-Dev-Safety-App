//
//  ContactTableViewCell.swift
//  This view controller is for configuring the cell of the table view in the Emergency Contact page.
//
//  Created by Beees on 9/6/2023.
//

import Foundation
import UIKit

// Listener method for edit button
protocol ContactCellDelegate: AnyObject {
    func didTapEditButton(in cell: ContactTableViewCell)
}

class ContactTableViewCell: UITableViewCell {

    var editButton: UIButton!
    var nameLabel: UILabel!
    var phoneNumberLabel: UILabel!
    
    weak var delegate: ContactCellDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    // Ui elements set up
    private func setupUI() {
        
        // Create buttons labels
        editButton = UIButton()
        editButton.setTitle("Edit", for: .normal)
        editButton.setTitleColor(.blue, for: .normal)
        editButton.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
        editButton.translatesAutoresizingMaskIntoConstraints = false
        
        nameLabel = UILabel()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        phoneNumberLabel = UILabel()
        phoneNumberLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(editButton)
        contentView.addSubview(nameLabel)
        contentView.addSubview(phoneNumberLabel)
        
        // Constraints set up
        NSLayoutConstraint.activate([
            editButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            editButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            nameLabel.leadingAnchor.constraint(equalTo: imageView!.trailingAnchor, constant: 10),
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            nameLabel.trailingAnchor.constraint(equalTo: editButton.leadingAnchor, constant: -10),
            
            phoneNumberLabel.leadingAnchor.constraint(equalTo: imageView!.trailingAnchor, constant: 10),
            phoneNumberLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 10),
            phoneNumberLabel.trailingAnchor.constraint(equalTo: editButton.leadingAnchor, constant: -10),
        ])
    }
    
    // Function to configure text fields
    func configureTextField(_ textField: UITextField, placeholder: String) {
        // Set placeholder string and attributes
        let placeholderAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.black
        ]
        textField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: placeholderAttributes)
        
        textField.borderStyle = .none
        textField.textColor = .black
        
        // Create a bottom border for the text field
        let bottomLine = UIView()
        bottomLine.translatesAutoresizingMaskIntoConstraints = false
        bottomLine.backgroundColor = .black
        textField.addSubview(bottomLine)
        
        NSLayoutConstraint.activate([
            bottomLine.leadingAnchor.constraint(equalTo: textField.leadingAnchor),
            bottomLine.trailingAnchor.constraint(equalTo: textField.trailingAnchor),
            bottomLine.bottomAnchor.constraint(equalTo: textField.bottomAnchor),
            bottomLine.heightAnchor.constraint(equalToConstant: 1)
        ])
    }
    
    // Update the cell contant
    func configure(with contact: EmergencyContact) {
        if let imageData = contact.imageData {
            imageView?.image = UIImage(data: imageData)
        }
        nameLabel.text = "Name: \(contact.name ?? "")"
        phoneNumberLabel.text = "Phone Number: \(contact.phoneNumber ?? "")"
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func editButtonTapped() {
        delegate?.didTapEditButton(in: self)
    }
}
