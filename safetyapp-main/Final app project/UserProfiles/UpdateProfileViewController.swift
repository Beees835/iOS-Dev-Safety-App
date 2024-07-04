//
//  UpdateProfileViewController.swift
//  This is for user's to update their profile if the wished to
//
//  Created by Beees on 7/6/2023.
//


import UIKit
import FirebaseAuth
import Firebase
import FirebaseStorage
import FirebaseFirestore

class UpdateProfileViewController: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    // MARK: - Properties
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var uploadImageButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    
    var selectedProfileImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupActions()
        uploadImageButton.addTarget(self, action: #selector(handleProfileImageViewTapped), for: .touchUpInside)
        self.view.backgroundColor = hexStringToUIColor(hex: "515A80")
        self.title = "Update Profile"
    }
    
    private func setupUI() {
        // Set up UI elements
        nameTextField.delegate = self
        nameTextField.attributedPlaceholder = NSAttributedString(string: "New Name",
                                                                 attributes: [NSAttributedString.Key.foregroundColor: UIColor.black])
        
        nameTextField.borderStyle = .none
        
        let lineView = UIView()
        lineView.translatesAutoresizingMaskIntoConstraints = false
        lineView.backgroundColor = .black
        nameTextField.addSubview(lineView)
        
        NSLayoutConstraint.activate([
            lineView.leadingAnchor.constraint(equalTo: nameTextField.leadingAnchor),
            lineView.trailingAnchor.constraint(equalTo: nameTextField.trailingAnchor),
            lineView.bottomAnchor.constraint(equalTo: nameTextField.bottomAnchor),
            lineView.heightAnchor.constraint(equalToConstant: 1)
        ])
        
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.clipsToBounds = true
        
        uploadImageButton.setTitle("Upload New Profile Image", for: .normal)
        saveButton.setTitle("Update Profile", for: .normal)
        
        // Disable autoresizing masks
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        nameTextField.translatesAutoresizingMaskIntoConstraints = false
        uploadImageButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Add constraints
        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            profileImageView.bottomAnchor.constraint(equalTo: nameTextField.topAnchor, constant: -90),
            
            nameTextField.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 20),
            nameTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nameTextField.widthAnchor.constraint(equalTo: uploadImageButton.widthAnchor), // Make the line as wide as the button
            
            uploadImageButton.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 40),
            uploadImageButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            uploadImageButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            
            saveButton.topAnchor.constraint(equalTo: uploadImageButton.bottomAnchor, constant: 30),
            saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30), // constant to set the distance from the bottom
            saveButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            
        ])
    }
    
    
    // Actions Setup
    private func setupActions() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleProfileImageViewTapped))
        profileImageView.isUserInteractionEnabled = true
        profileImageView.addGestureRecognizer(tapGesture)
    }
    
    // Handlers
    @objc private func handleProfileImageViewTapped() {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.allowsEditing = true
        present(pickerController, animated: true, completion: nil)
    }
    
    @IBAction func uploadButtonTapped(_ sender: Any) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        
        // Using action sheet so the user can choose image source from cmaera or library
        let actionSheet = UIAlertController(title: "Photo Source", message: "Choose a source", preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action:UIAlertAction) in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                imagePickerController.sourceType = .camera
                self.present(imagePickerController, animated: true, completion: nil)
            } else {
                print("Camera not available")
            }
        }))
    
        actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { (action:UIAlertAction) in
            imagePickerController.sourceType = .photoLibrary
            self.present(imagePickerController, animated: true, completion: nil)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        guard let image = selectedProfileImage else {
            showAlert(message: "Please upload a profile image")
            return
        }
        guard let name = nameTextField.text, !name.isEmpty else {
            showAlert(message: "Please enter a name")
            return
        }
        
        // Convert UIImage to Data
        guard let imageData = image.jpegData(compressionQuality: 0.5) else {
            print("Could not convert UIImage to Data.")
            return
        }
        
        // Upload image to Firebase Storage
        uploadImageToFirebase(imageData: imageData, completion: { (profileImageUrl) in
            self.updateProfile(name: name, profileImageUrl: profileImageUrl)
            self.dismiss(animated: true, completion: nil)
        })
    }
    
    func uploadImageToFirebase(imageData: Data, completion: @escaping (_ imageUrl: String)->()) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        // Sotring data in collection "users" that has "images" child field to save the url
        let storageRef = Storage.storage().reference().child("images").child("\(uid).jpg")
        
        // Push data to Could with error catching
        storageRef.putData(imageData, metadata: nil, completion: { (metadata, error) in
            if error != nil {
                print(error!.localizedDescription)
                return
            }
        
            storageRef.downloadURL(completion: { (url, error) in
                if error != nil {
                    print(error!.localizedDescription)
                    return
                }
                if let profileImageUrl = url?.absoluteString {
                    completion(profileImageUrl)
                }
            })
        })
    }
    
    func updateProfile(name: String, profileImageUrl: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        
        // updating the user's name and image in the "users" collection
        db.collection("users").document(uid).updateData([
            "name": name,
            "image": profileImageUrl
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated!")
                // Show an alert to notify the user
                let alert = UIAlertController(title: "Profile Updated", message: "Your profile has been successfully updated.", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(okAction)
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            profileImageView.image = editedImage
            selectedProfileImage = editedImage
        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            profileImageView.image = originalImage
            selectedProfileImage = originalImage
        }
        saveButton.isEnabled = true
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
