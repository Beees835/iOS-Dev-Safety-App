//
//  initialPageViewController.swift
//  Final app project
//
//  Created by Beees on 20/4/2023.
//

import UIKit

class initialPageViewController: UIViewController {
    
    @IBOutlet weak var welcome: UILabel!{
        didSet{
            welcome.text = "Welcome"
            welcome.textAlignment = .center
            welcome.textColor = .black
            welcome.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    @IBOutlet weak var login: UIButton!{
        didSet{
            login.setTitle("Login", for: .normal)
            login.backgroundColor = .blue
            login.setTitleColor(.black, for: .normal)
            login.layer.cornerRadius = 10
            login.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    @IBOutlet weak var signup: UIButton!{
        didSet{
            signup.setTitle("Sign Up", for: .normal)
            signup.backgroundColor = .blue
            signup.setTitleColor(.black, for: .normal)
            signup.layer.cornerRadius = 10
            signup.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = hexStringToUIColor(hex: "515A80")
        
        setupLayout()
    }
    
    private func setupLayout() {
        let stackView = UIStackView(arrangedSubviews: [welcome, login, signup])
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.spacing = 20
        
        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8)
        ])
    }
    
}
