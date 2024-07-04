//
//  EditContactViewController.swift
//  Final app project
//
//  Created by Beees on 9/6/2023.
//

import Foundation
import UIKit


protocol EditContactViewControllerDelegate: AnyObject {
    func didFinishEditing()
}

class EditContactViewController: UIViewController {
    
    var contact: EmergencyContact
    weak var delegate: EditContactViewControllerDelegate?
    
    private var nameTextField: UITextField!
    private var phoneNumberTextField: UITextField!
    private var saveButton: UIBarButtonItem!
    
    init(contact: EmergencyContact) {
        self.contact = contact
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Edit Contact"
        self.view.backgroundColor = .white
        
        setupUI()
        setupNavigationBar()
        self.view.backgroundColor = hexStringToUIColor(hex: "515A80")
    }
    
    private func setupUI() {
        // Create and configure text fields for editing
        nameTextField = UITextField()
        nameTextField.text = contact.name
        
        nameTextField.textColor = UIColor.black
        nameTextField.borderStyle = .none
        nameTextField.translatesAutoresizingMaskIntoConstraints = false
        
        let nameLineView = UIView()
        nameLineView.backgroundColor = .black
        nameLineView.translatesAutoresizingMaskIntoConstraints = false
        
        phoneNumberTextField = UITextField()
       
        phoneNumberTextField.text = contact.phoneNumber
        nameTextField.textColor = UIColor.black
        phoneNumberTextField.borderStyle = .none
        phoneNumberTextField.translatesAutoresizingMaskIntoConstraints = false
        
        let phoneNumberLineView = UIView()
        phoneNumberLineView.backgroundColor = .black
        phoneNumberLineView.translatesAutoresizingMaskIntoConstraints = false
        
        // Add line views as subviews of text fields
        nameTextField.addSubview(nameLineView)
        phoneNumberTextField.addSubview(phoneNumberLineView)
        
        configureTextField(phoneNumberTextField, placeholder: "Phone Number")
        configureTextField(nameTextField, placeholder: "Name")
        
        // Configure constraints for line views
        NSLayoutConstraint.activate([
            nameLineView.leadingAnchor.constraint(equalTo: nameTextField.leadingAnchor),
            nameLineView.trailingAnchor.constraint(equalTo: nameTextField.trailingAnchor),
            nameLineView.bottomAnchor.constraint(equalTo: nameTextField.bottomAnchor),
            nameLineView.heightAnchor.constraint(equalToConstant: 1.0),
            
            phoneNumberLineView.leadingAnchor.constraint(equalTo: phoneNumberTextField.leadingAnchor),
            phoneNumberLineView.trailingAnchor.constraint(equalTo: phoneNumberTextField.trailingAnchor),
            phoneNumberLineView.bottomAnchor.constraint(equalTo: phoneNumberTextField.bottomAnchor),
            phoneNumberLineView.heightAnchor.constraint(equalToConstant: 1.0)
        ])
        
        // Create a vertical stack view for the text fields
        let stackView = UIStackView(arrangedSubviews: [nameTextField, phoneNumberTextField])
        stackView.axis = .vertical
        stackView.spacing = 20.0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        
        // Add the stack view to the view controller's view
        view.addSubview(stackView)
        
        // Configure constraints for the stack view
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8)
        ])
        
        // Add target actions to text fields for editing events
        nameTextField.addTarget(self, action: #selector(textFieldEditingChanged), for: .editingChanged)
        phoneNumberTextField.addTarget(self, action: #selector(textFieldEditingChanged), for: .editingChanged)
    }
    
    private func setupNavigationBar() {
        // Add a "Save" button to the navigation bar
        saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveButtonTapped))
        saveButton.isEnabled = false
        navigationItem.rightBarButtonItem = saveButton
    }
    
    @objc private func textFieldEditingChanged() {
        // Enable/disable the save button based on text field changes
        let nameText = nameTextField.text ?? ""
        let phoneNumberText = phoneNumberTextField.text ?? ""
        saveButton.isEnabled = !nameText.isEmpty || !phoneNumberText.isEmpty
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
    
    @objc private func saveButtonTapped() {
        // Update the contact with the new values from the text fields
        contact.name = nameTextField.text
        contact.phoneNumber = phoneNumberTextField.text
        
        // Save the changes to CoreData
        do {
            try contact.managedObjectContext?.save()
            delegate?.didFinishEditing()
            navigationController?.popViewController(animated: true)
        } catch {
            print("Failed to save contact: \(error)")
        }
    }
}
