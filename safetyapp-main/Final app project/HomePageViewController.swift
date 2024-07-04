//
//  HomePageViewController.swift
//  Final app project
//
//  Created by Beees on 20/4/2023.
//

import UIKit
import FirebaseAuth
import Firebase

class HomePageViewController: UIViewController {
    
    @IBOutlet weak var greeting: UILabel!
    @IBOutlet weak var CallByCountry: UIButton!
    @IBOutlet weak var EmergencyContact: UIButton!
    @IBOutlet weak var USCrimeData: UIButton!
    @IBOutlet weak var userProfileImageView: UIImageView!
    @IBOutlet weak var ChangeProfileButton: UIButton!
    var profileListener: ListenerRegistration?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        listenForProfileChanges()
        setupUI()
        
        // Initialize UI and load data
        loadProfileDataWithAnimation()
        self.hideKeyboardWhenTappedAround()
        
        // Set background color
        // Helper function found on stackoverflow, detail in extension file.
        self.view.backgroundColor = hexStringToUIColor(hex: "515A80")
        
        // Start listening for Firestore updates
        listenForProfileChanges()
    }
    
    private func setupUI() {
        // Setup for all UI elements
        greeting.font = UIFont.boldSystemFont(ofSize: 24)
        greeting.textColor = .label
        greeting.text = "Hi,"
        greeting.textAlignment = .center
        
        CallByCountry.setTitle("Emergency Call By Countries", for: .normal)
        CallByCountry.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        CallByCountry.setTitleColor(.white, for: .normal)
        
        EmergencyContact.setTitle("Set Up Your Emergency Contacts!", for: .normal)
        EmergencyContact.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        EmergencyContact.setTitleColor(.white, for: .normal)
        
        USCrimeData.setTitle("US National Crime Data", for: .normal)
        USCrimeData.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        USCrimeData.setTitleColor(.white, for: .normal)
        
        ChangeProfileButton.setTitle("Change Profile", for: .normal)
        ChangeProfileButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        ChangeProfileButton.setTitleColor(.white, for: .normal)
        
        userProfileImageView.translatesAutoresizingMaskIntoConstraints = false
        greeting.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            userProfileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            userProfileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            userProfileImageView.heightAnchor.constraint(equalToConstant: 120),
            userProfileImageView.widthAnchor.constraint(equalToConstant: 120),
            
            greeting.topAnchor.constraint(equalTo: userProfileImageView.bottomAnchor, constant: 16),
            greeting.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            greeting.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
        
        let buttons = [CallByCountry, EmergencyContact, USCrimeData, ChangeProfileButton]
        
        // Create a stack view
        let stackView = UIStackView(arrangedSubviews: buttons as! [UIView])
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 25 // Adjust the spacing between the buttons here
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stackView)
        
        // Add constraints for the stack view
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: greeting.bottomAnchor, constant: 0), // Adjust the distance between the greeting and the stack view here
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30), // maintain a 30 points distance from bottom
            stackView.widthAnchor.constraint(equalToConstant: 350), // Adjust the width of the buttons here
            stackView.heightAnchor.constraint(equalToConstant: 400) // Adjust the height of the buttons here
            
        ])
        
        userProfileImageView.layer.cornerRadius = userProfileImageView.frame.width / 2
        userProfileImageView.clipsToBounds = true
    }
    
    // Loading profile data with a nice fade-in animation
    private func loadProfileDataWithAnimation() {
        greeting.text = "Hi,"
        userProfileImageView.image = UIImage(named: "placeholder_profile")
        
        // Animate the UI setup and load the profile data afterwards
        UIView.animate(withDuration: 0.3, animations: {
            self.setupUI()
        }) { _ in
            self.loadProfileData()
        }
    }
    
    
    // Loading profile data
    private func loadProfileData() {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("Error: No current user found.")
            return
        }
        
        // Create Firestore instance for storing data
        let db = Firestore.firestore()
        let docRef = db.collection("users").document(uid)
        
        docRef.getDocument { [weak self] (document, error) in
            guard let strongSelf = self else {
                print("Error: Self is nil.")
                return
            }
            
            // error catching
            if let error = error {
                print("Error getting document: \(error.localizedDescription)")
            } else {
                // start fetching data from firebase if document found
                if let document = document, document.exists {
                    let data = document.data()
                    let name = data?["name"] as? String ?? ""
                    
                    // Then start updating UI with greeting message
                    DispatchQueue.main.async {
                        strongSelf.greeting.text = "Hi, " + name
                        strongSelf.showUIElementsWithAnimation()
                    }
                    
                    // Loading image url from firebase with animation
                    if let profileImageUrl = data?["image"] as? String {
                        strongSelf.loadImageWithAnimation(from: profileImageUrl)
                    } else {
                        print("Error: No profile image URL found.")
                    }
                } else {
                    print("Document does not exist")
                }
            }
        }
    }
    
    private func showUIElementsWithAnimation() {
        UIView.animate(withDuration: 0.3) {
            self.greeting.alpha = 1.0
            self.CallByCountry.alpha = 1.0
            self.EmergencyContact.alpha = 1.0
            self.USCrimeData.alpha = 1.0
            self.userProfileImageView.alpha = 1.0
        }
    }
    
    // animation for image loading on home page
    // Source: Chatgpt
    private func loadImageWithAnimation(from urlString: String) {
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
            if let error = error {
                print("Error loading image: \(error.localizedDescription)")
                return
            }
            DispatchQueue.main.async {
                UIView.transition(with: self?.userProfileImageView ?? UIView(), duration: 0.3, options: .transitionCrossDissolve, animations: {
                    if let data = data, let downloadedImage = UIImage(data: data) {
                        self?.userProfileImageView.image = downloadedImage
                    } else {
                        print("Error: Image data could not be converted to UIImage.")
                    }
                }, completion: nil)
            }
        }.resume()
    }
    
    // Log out function this asks user if confirm whether they want to log out or not in case fat finger
    @IBAction func logout(_ sender: Any) {
        let alert = UIAlertController(title: "Confirmation", message: "Are you sure you want to log out?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (_) in
            self.performLogout()
        }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    
    // Listen for profile changes
    func listenForProfileChanges() {
        
        // Ensure there's a logged-in user
        guard let uid = Auth.auth().currentUser?.uid else {
            print("Error: No current user found.")
            return
        }
        
        let db = Firestore.firestore()
        let docRef = db.collection("users").document(uid)
        
        // Start listening for changes
        profileListener = docRef.addSnapshotListener { [weak self] (documentSnapshot, error) in
            guard let strongSelf = self else {
                print("Error: Self is nil.")
                return
            }
            
            if let error = error {
                print("Error listening for document updates: \(error)")
            } else {
                if let document = documentSnapshot, document.exists {
                    let data = document.data()
                    let name = data?["name"] as? String ?? ""
                    
                    // Update UI elements
                    DispatchQueue.main.async {
                        strongSelf.greeting.text = "Hi, " + name
                        strongSelf.showUIElementsWithAnimation()
                    }
                    
                    if let profileImageUrl = data?["image"] as? String {
                        strongSelf.loadImageWithAnimation(from: profileImageUrl)
                    } else {
                        print("Error: No profile image URL found.")
                    }
                } else {
                    print("Document does not exist")
                }
            }
        }
    }
    
    // Log out process if use choose yes
    func performLogout() {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            _ = UserDefaults.standard
            
            // remember me for email user has entered.
            UserDefaults.standard.set(false, forKey: "rememberMe")
            
            // Then segue to the sign in page and change the root view to avoid screen stacking together
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let loginNavController = storyboard.instantiateViewController(identifier: "loginPage")
            (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(loginNavController)
            print("Signed out")
    
            let vc = LoginViewController()
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: false)
            // error catching
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
    
    // Clean up the listener when the view controller is deinitialized
    deinit {
        profileListener?.remove()
    }
}
