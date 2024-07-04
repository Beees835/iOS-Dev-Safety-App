//
//  SignupViewController.swift
//  Final app project
//
//  Created by Beees on 20/4/2023.
//

import UIKit
import FirebaseAuth
import Firebase
import FirebaseCore

class SignupViewController: UIViewController, UITextFieldDelegate {
    

    var isSecureTextEntry: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Hiding the password for extra security layer
        self.password.delegate = self
        self.password.textContentType = .password
        self.password.isSecureTextEntry = true
        
        // Gesture detection to hide the keyboard
        self.hideKeyboardWhenTappedAround()
    
        setupConstraints()
        
        self.view.backgroundColor = hexStringToUIColor(hex: "515A80")
    }
    
    // UI elements set up using vertical stack view and constraints
    @IBOutlet weak var email: UITextField!{
        didSet {
            email.delegate = self
            email.attributedPlaceholder = NSAttributedString(string: "Email",
                                                             attributes: [NSAttributedString.Key.foregroundColor: UIColor.black])
            email.borderStyle = .none
            
            let lineView = UIView()
            lineView.translatesAutoresizingMaskIntoConstraints = false
            lineView.backgroundColor = .black
            email.addSubview(lineView)
            
            NSLayoutConstraint.activate([
                lineView.leadingAnchor.constraint(equalTo: email.leadingAnchor),
                lineView.trailingAnchor.constraint(equalTo: email.trailingAnchor),
                lineView.bottomAnchor.constraint(equalTo: email.bottomAnchor),
                lineView.heightAnchor.constraint(equalToConstant: 1)
            ])
        }
    }
    
    @IBOutlet weak var password: UITextField!{
        didSet{
            password.delegate = self
            password.attributedPlaceholder = NSAttributedString(string: "Password",
                                                                attributes: [NSAttributedString.Key.foregroundColor: UIColor.black])
            password.borderStyle = .none
            
            let lineView = UIView()
            lineView.translatesAutoresizingMaskIntoConstraints = false
            lineView.backgroundColor = .black
            password.addSubview(lineView)
            
            NSLayoutConstraint.activate([
                lineView.leadingAnchor.constraint(equalTo: password.leadingAnchor),
                lineView.trailingAnchor.constraint(equalTo: password.trailingAnchor),
                lineView.bottomAnchor.constraint(equalTo: password.bottomAnchor),
                lineView.heightAnchor.constraint(equalToConstant: 1)
            ])
        }
    }
    
    @IBOutlet weak var signUpStackView: UIStackView!{
        didSet {
            signUpStackView.axis = .vertical
            signUpStackView.alignment = .fill
            signUpStackView.distribution = .equalSpacing
            signUpStackView.spacing = 20
            signUpStackView.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            signUpStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            signUpStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            signUpStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            signUpStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50)
        ])
    }
    
    // Sign up
    @IBAction func signup(_ sender: Any) {
        
        // First check for user imput errors
        // Then prompt error message
        // if all passed then move on to create new user in firebase
        if email.text == "" || password.text == "" {
            let alert = UIAlertController(title: "Error", message: "Please enter an email and password", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
        } else {
            Auth.auth().createUser(withEmail: email.text!, password: password.text!) { authResult, error in
                if error == nil {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let mainTabBarController = storyboard.instantiateViewController(identifier: "RegistrationDetailsViewController")
                    
                    // This is to get the SceneDelegate object from your view controller
                    // then call the change root view controller function to change to main tab bar
                    (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(mainTabBarController)
                } else {
                    let alert = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true)
                }
            }
        }
    }
    
    // Segue to signin page 
    @IBAction func goSignIn(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainTabBarController = storyboard.instantiateViewController(identifier: "loginPage")
        
        // This is to get the SceneDelegate object from view controller
        // then call the change root view controller function to change to main tab bar
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(mainTabBarController)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goHomePage" {
            guard segue.destination is HomePageViewController else { return }
        }
    }
    
}
