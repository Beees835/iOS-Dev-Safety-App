//
//  AddContactViewController.swift
//  Final app project
//
//  Created by Beees on 16/5/2023.
//

import UIKit
import CoreData

// Protocol for notifying when a contact is added or updated
protocol AddContactViewControllerDelegate: AnyObject {
    func didAddContact()
    func didUpdateContact()
}

class AddContactViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var phoneNumber: UITextField!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var selectImage: UIButton!
    @IBOutlet weak var save: UIButton!

    weak var delegate: AddContactViewControllerDelegate?

    var imagePicker: UIImagePickerController?
    var context: NSManagedObjectContext!


    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Safely unwrap AppDelegate
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("AppDelegate unavailable")
        }
        
        setupUI()
        context = appDelegate.persistentContainerEmergencyContact.viewContext
        
        // Configure image picker
        imagePicker = UIImagePickerController()
        imagePicker?.delegate = self
        
        // Additional UI configurations
        self.hideKeyboardWhenTappedAround()
        self.view.backgroundColor = hexStringToUIColor(hex: "515A80")
    }
    
    private func setupUI() {
        // Configure imageView
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .gray
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.heightAnchor.constraint(equalToConstant: 200).isActive = true

        // Configure selectImage button
        selectImage.setTitle("Select Image", for: .normal)
        selectImage.translatesAutoresizingMaskIntoConstraints = false
        selectImage.addTarget(self, action: #selector(selectImageTapped), for: .touchUpInside)

        // Configure save button
        save.setTitle("Save Contact", for: .normal)
        save.translatesAutoresizingMaskIntoConstraints = false
        save.addTarget(self, action: #selector(saveContactTapped), for: .touchUpInside)

        // Configure the text fields
        configureTextField(name, placeholder: "Name")
        configureTextField(phoneNumber, placeholder: "Phone Number")
        
        // heights of the button
        save.heightAnchor.constraint(equalToConstant: 55).isActive = true
        selectImage.heightAnchor.constraint(equalToConstant: 55).isActive = true

        // Create a vertical stack view
        let stackView = UIStackView(arrangedSubviews: [imageView, name, phoneNumber, selectImage, save])
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.alignment = .fill
        stackView.spacing = 15

        // Add the stack view to super view (i.e. self.view)
        view.addSubview(stackView)

        // Set the constraints for stack view
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50)
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
    
    
    // MARK: - Actions
  
    @objc func selectImageTapped(_ sender: UIButton) {
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
            print("Photo library is not available.")
            return
        }
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        
        present(imagePicker, animated: true, completion: nil)
    }

    
    @objc func saveContactTapped(_ sender: UIButton) {
        // Check if name and phone number are not empty for error catching else save
        guard let contactName = name.text, !contactName.isEmpty else {
            displayAlert(message: "Please enter a contact name.")
            return
        }
        
        guard let contactPhoneNumber = phoneNumber.text, !contactPhoneNumber.isEmpty else {
            displayAlert(message: "Please enter a contact phone number.")
            return
        }
        
        guard let contactIcon = imageView.image else {
            displayAlert(message: "Please select an icon for the contact.")
            return
        }
        
        // Save the contact and update the delegate
        saveContactToCoreData(name: contactName, phoneNumber: contactPhoneNumber, icon: contactIcon)
    }
    
    
    func saveContactToCoreData(name: String, phoneNumber: String, icon: UIImage) {
        // Create a new Contact object in context
        let newContact = EmergencyContact(context: self.context)
        
        newContact.name = name
        newContact.phoneNumber = phoneNumber
        
        // Convert UIImage to Data
        guard let imageData = icon.pngData() else {
            print("Could not convert UIImage to Data.")
            return
        }
        
        newContact.imageData = imageData
        
        // Save the contact to CoreData and update the delegate if there is no error
        // Then use delegate as listener notify the change so UI can be updated
        do {
            try context.save()
            delegate?.didAddContact()
            delegate?.didUpdateContact()
            navigationController?.popViewController(animated: true)
        } catch {
            print("Failed to save contact: \(error)")
        }
    }


    // Image picker controller delegate methods
    // Allow the users to choose the source of their image 
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            imageView.image = editedImage
        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageView.image = originalImage
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    // Display alert
    func displayAlert(message: String) {
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(defaultAction)
        present(alertController, animated: true, completion: nil)
    }
}
