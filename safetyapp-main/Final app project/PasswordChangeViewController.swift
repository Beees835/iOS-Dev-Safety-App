//
//  PasswordChangeViewController.swift
//  Final app project
//
//  Created by Beees on 24/5/2023.
//

import UIKit
import Firebase

class PasswordChangeViewController: UIViewController {
    
    // UI elements
    var currentPassword: UITextField!
    var newPassword: UITextField!
    var confirmNewPassword: UITextField!
    var errorLabel: UILabel!
    var changePasswordButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Instantiate UI elements
        currentPassword = createTextField(placeholder: "Current Password")
        newPassword = createTextField(placeholder: "New Password")
        confirmNewPassword = createTextField(placeholder: "Confirm New Password")
        changePasswordButton = createButton(title: "Change Password")
        errorLabel = createErrorLabel()
        
        // Add UI elements to stack view
        let stackView = UIStackView(arrangedSubviews: [currentPassword, newPassword, confirmNewPassword, changePasswordButton, errorLabel])
        stackView.axis = .vertical
        stackView.spacing = 25
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        self.title = "Password Change"
        self.view.addSubview(stackView)
        self.view.backgroundColor = hexStringToUIColor(hex: "515A80")
        
        // Setup layout
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 80),
            stackView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
        ])
        
        self.hideKeyboardWhenTappedAround()
    }
    
    // Textfield initialization
    func createTextField(placeholder: String) -> UITextField {
        let textField = UITextField()
        textField.attributedPlaceholder = NSAttributedString(string: placeholder,
                                                             attributes: [NSAttributedString.Key.foregroundColor: UIColor.black])
        textField.borderStyle = .none
        createBottomLine(for: textField)
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }
    
    // Error label initialization
    func createErrorLabel() -> UILabel {
        let label = UILabel()
        label.textColor = .red
        label.numberOfLines = 0
        label.textAlignment = .center
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    //Button UI initialization
    func createButton(title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.tintColor = UIColor.white
        button.setTitle(title, for: .normal)
        button.addTarget(self, action: #selector(changePasswordButtonPressed(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }
    
    private func createBottomLine(for textField: UITextField) {
        let lineView = UIView()
        lineView.translatesAutoresizingMaskIntoConstraints = false
        lineView.backgroundColor = .black
        textField.addSubview(lineView)
        
        NSLayoutConstraint.activate([
            lineView.leadingAnchor.constraint(equalTo: textField.leadingAnchor),
            lineView.trailingAnchor.constraint(equalTo: textField.trailingAnchor),
            lineView.bottomAnchor.constraint(equalTo: textField.bottomAnchor),
            lineView.heightAnchor.constraint(equalToConstant: 1)
        ])
    }


    @objc func changePasswordButtonPressed(_ sender: UIButton) {
        guard let currentPassword = currentPassword.text,
              let newPassword = newPassword.text,
              let confirmNewPassword = confirmNewPassword.text
        else {
            showError("Please fill in all fields.")
            return
        }
        
        if currentPassword.isEmpty || newPassword.isEmpty || confirmNewPassword.isEmpty {
            showError("Please fill in all fields.")
            return
        }
        
        if newPassword != confirmNewPassword {
            showError("New passwords do not match.")
            return
        }
        
        if newPassword.count < 6 {
            showError("Password must be at least 6 characters.")
            return
        }
        
        // Get current user
        if let user = Auth.auth().currentUser, let email = user.email {
            // Create credential
            let credential = EmailAuthProvider.credential(withEmail: email, password: currentPassword)
            
            // Re-authenticate user
            user.reauthenticate(with: credential) { (result, error) in
                if error != nil {
                    self.showError("Failed to re-authenticate. Please check your current password.")
                    return
                }
                
                // Change password
                user.updatePassword(to: newPassword) { (error) in
                    if error != nil {
                        self.showError("Failed to update password. Please try again later.")
                        return
                    }
                    
                    // Password updated successfully
                    self.showError("Password updated successfully!")
                }
            }
        }
    }
    
    func showError(_ message: String) {
        errorLabel.text = message
        errorLabel.isHidden = false
    }
}
