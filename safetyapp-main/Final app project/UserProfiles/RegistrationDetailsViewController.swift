//
//  RegistrationDetailsViewController.swift
//  This is for the user to register their name and profile picture
//
//  Created by Beees on 28/5/2023.
//

import UIKit
import FirebaseAuth
import Firebase
import FirebaseFirestore
import FirebaseStorage

class RegistrationDetailsViewController: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    // MARK: - Properties
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var uploadImageButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    
    // Hold the selected image for profile picture
    var selectedProfileImage: UIImage?
    
    // This method is called after the controller's view is loaded into memory
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up the UI for the view
        setupUI()
        
        // Set up the actions for the view, such as tap gesture for profile image
        setupActions()
        
        // Set the event listener for the upload button
        uploadImageButton.addTarget(self, action: #selector(handleProfileImageViewTapped), for: .touchUpInside)
        
        // Set the background color for the view
        self.view.backgroundColor = hexStringToUIColor(hex: "515A80")
    }
    
    private func setupUI() {
        // Using Auto Layout programmatically instead of storyboard
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        nameTextField.translatesAutoresizingMaskIntoConstraints = false
        uploadImageButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Set the constraints for the UI components
        NSLayoutConstraint.activate([
            // SaveButton setup
            saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            saveButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 30),
            saveButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -30),
            saveButton.heightAnchor.constraint(equalToConstant: 50),
            
            // UploadImageButton setup
            uploadImageButton.bottomAnchor.constraint(equalTo: saveButton.topAnchor, constant: -20),
            uploadImageButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 30),
            uploadImageButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -30),
            uploadImageButton.heightAnchor.constraint(equalToConstant: 50),
            
            // Name TextField setup
            nameTextField.bottomAnchor.constraint(equalTo: uploadImageButton.topAnchor, constant: -60),
            nameTextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 30),
            nameTextField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -30),
            
            // Profile ImageView setup
            profileImageView.bottomAnchor.constraint(equalTo: nameTextField.topAnchor, constant: -150),
            profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 150),
            profileImageView.heightAnchor.constraint(equalTo: profileImageView.widthAnchor),
        ])
        
        // Setup the nameTextField UI properties
        nameTextField.delegate = self
        nameTextField.attributedPlaceholder = NSAttributedString(string: "Enter your name",
                                                                 attributes: [NSAttributedString.Key.foregroundColor: UIColor.black])
        nameTextField.borderStyle = .none  // Remove the border of the text field
        
        // Create and add a line view at the bottom of the nameTextField to give a single line effect
        let lineView = UIView()
        lineView.translatesAutoresizingMaskIntoConstraints = false
        lineView.backgroundColor = .black  // Black color line
        nameTextField.addSubview(lineView)  // Add the line view to the nameTextField
        
        // Add Auto Layout constraints to the line view
        NSLayoutConstraint.activate([
            lineView.leadingAnchor.constraint(equalTo: nameTextField.leadingAnchor),
            lineView.trailingAnchor.constraint(equalTo: nameTextField.trailingAnchor),
            lineView.bottomAnchor.constraint(equalTo: nameTextField.bottomAnchor),
            lineView.heightAnchor.constraint(equalToConstant: 0.5),  // Half point line
        ])
        
        // Set the UI properties for the profileImageView
        profileImageView.contentMode = .scaleAspectFill  // Aspect fill mode for the profile image view
        profileImageView.layer.cornerRadius = 75  // Half of the width to make it a circle
        profileImageView.layer.masksToBounds = true  // Clips the image to the bounds of the image view (to make it a circle)
        profileImageView.image = UIImage(named: "placeholder")  // Default profile image
        
        // Setup the UI properties for the uploadImageButton
        uploadImageButton.setTitle("Upload a picture", for: .normal)
        uploadImageButton.setTitleColor(.white, for: .normal)
        
        // Setup the UI properties for the saveButton
        saveButton.setTitle("Save Profile", for: .normal)
        saveButton.setTitleColor(.white, for: .normal)
    }
    
    
    // Set up the actions such as gesture recognizers
    // When the user taps on the icon area they can choose ther icon or they can choose to press the button
    private func setupActions() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleProfileImageViewTapped))
        profileImageView.addGestureRecognizer(tapGesture)
        profileImageView.isUserInteractionEnabled = true
    }
    
    // Handle the event when the profile image view is tapped
    @objc private func handleProfileImageViewTapped() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    // This is a delegate method that gets called when an image is picked
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            selectedProfileImage = editedImage
        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            selectedProfileImage = originalImage
        }
        
        if let selectedImage = selectedProfileImage {
            profileImageView.image = selectedImage
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    // This is the action handler for the saveButton
    @IBAction func handleSaveButtonTapped(_ sender: Any) {
        saveButton.isEnabled = false
        guard let name = nameTextField.text else { return }
        saveProfile(name: name)
    }
    
    // This function saves the profile information to Firebase
    func saveProfile(name: String) {
        guard let image = selectedProfileImage, let imageData = image.jpegData(compressionQuality: 0.1) else { return }
        
        let storageRef = Storage.storage().reference().child("image").child("\(UUID().uuidString).jpg")
        
        // Metadata
        let uploadMetadata = StorageMetadata()
        uploadMetadata.contentType = "image/jpeg"
        
        storageRef.putData(imageData, metadata: uploadMetadata) { (metadata, error) in
            if let error = error {
                print("Error occurred: \(error.localizedDescription)")
                return
            }
            
            // Retrieve download URL
            storageRef.downloadURL { (url, error) in
                guard let downloadURL = url else {
                    print("An error occurred while getting download URL")
                    return
                }
                
                self.saveProfile(name: name, profileImageUrl: downloadURL.absoluteString)
            }
        }
    }
    
    // This function stores the profile information into Firestore
    func saveProfile(name: String, profileImageUrl: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        
        // Saved info into Firebase
        db.collection("users").document(uid).setData([
            "name": name,
            "image": profileImageUrl
        ]) { err in
            // Then error chatching if success then go to Home Page
            if let err = err {
                print("Error writing document: \(err)")
                self.saveButton.isEnabled = true
            } else {
                print("Profile successfully written!")
                self.navigateToHomePage()
            }
        }
    }
    
    func navigateToHomePage() {
        
        // Navigate to the home page within the tab bar controller
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainTabBarController = storyboard.instantiateViewController(identifier: "tabBar")
        
        
        // This is to get the SceneDelegate object from your view controller
        // then call the change root view controller function to change to main tab bar
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(mainTabBarController)
        
    }
}

