//
//  LoginViewController.swift
//  Final app project
//
//  Created by Beees on 20/4/2023.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseCore


class LoginViewController: UIViewController, UITextInputTraits, UITextFieldDelegate {
    
    // Hide the password when the user is entering
    var isSecureTextEntry: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Hiding the password for extra security layer
        self.password.delegate = self
        self.password.textContentType = .password
        self.password.isSecureTextEntry = true
        
        self.hideKeyboardWhenTappedAround()
        self.view.backgroundColor = hexStringToUIColor(hex: "515A80")
        
        // Remember the email so it allows the user sign in quicker
        if let savedEmail = UserDefaults.standard.string(forKey: "email") {
            email.text = savedEmail
        }
        setupConstraints()
    }
    
    
    @IBOutlet weak var email: UITextField! {
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
    
    @IBOutlet weak var password: UITextField! {
        didSet {
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
    
    
    @IBOutlet weak var loginStackView: UIStackView!{
        didSet {
            loginStackView.axis = .vertical
            loginStackView.alignment = .fill
            loginStackView.distribution = .equalSpacing
            loginStackView.spacing = 20
            loginStackView.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            loginStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loginStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            loginStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            loginStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50)
        ])
    }
    
    
    // Verifying the user is logged in
    @IBAction func Signin(_ sender: Any) {
        if email.text == "" || password.text == "" {
            let alert = UIAlertController(title: "Error", message: "Please enter an email and password", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
        } else {
            Auth.auth().signIn(withEmail: email.text!, password: password.text!) { [weak self] authResult, error in
                guard let strongSelf = self else { return }
                
                if let error = error {
                    let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    strongSelf.present(alert, animated: true)
                } else {
                    strongSelf.showLoadingIndicator {
                        strongSelf.fetchProfileData {
                            strongSelf.hideLoadingIndicator {
                                strongSelf.navigateToHomePage()
                            }
                        }
                    }
                }
            }
        }
    }
    
    // This is loading animation. When user log in it will have a spin circleing indicating loading process.
    private func showLoadingIndicator(completion: @escaping () -> Void) {
        let loadingView = UIView(frame: view.bounds)
        loadingView.backgroundColor = UIColor(white: 0, alpha: 0.7)
        loadingView.tag = 100
        
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.color = .white
        activityIndicator.center = loadingView.center
        activityIndicator.startAnimating()
        loadingView.addSubview(activityIndicator)
        
        view.addSubview(loadingView)
        
        // Perform data fetching operations during the transition animation
        fetchProfileData {
            // Call completion block when data fetching is complete
            completion()
        }
    }
    
    // This is to hide the loading animation after finished
    private func hideLoadingIndicator(completion: @escaping () -> Void) {
        if let loadingView = view.viewWithTag(100) {
            loadingView.removeFromSuperview()
        }
        
        // Call completion block after hiding the loading indicator
        completion()
    }
    
    
    private func fetchProfileData(completion: @escaping () -> Void) {
        // Simulate fetching profile data for 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            // Perform necessary data fetching operations here
            
            // Call completion block when data fetching is complete
            completion()
        }
    }
    
    private func navigateToHomePage() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainTabBarController = storyboard.instantiateViewController(identifier: "tabBar")
    
        
        // This is to get the SceneDelegate object from your view controller
        // then call the change root view controller function to change to main tab bar
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(mainTabBarController)
    }
    
    
    @IBAction func goSignUp(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainTabBarController = storyboard.instantiateViewController(identifier: "signUpPage")
        
        // This is to get the SceneDelegate object from your view controller
        // then call the change root view controller function to change to main tab bar
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(mainTabBarController)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goHomePage" {
            guard segue.destination is HomePageViewController else { return }
        }
    }
}
    

    


