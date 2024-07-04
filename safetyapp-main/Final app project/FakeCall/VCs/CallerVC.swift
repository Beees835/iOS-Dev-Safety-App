//
//  CallerVC.swift
//  FakeCallPro
//
//  Created by Ankit Saxena on 25/02/19.
//  Copyright © 2019 Ankit Saxena. All rights reserved.
//

import UIKit

protocol callerNameDelegate {
    func callerName(cName: String, dName: String)
}

class CallerVC: UIViewController {
    
    @IBOutlet weak var nameLabel: UILabel! // Label for the name field
    @IBOutlet weak var deviceLabel: UILabel! // Label for the device field
    @IBOutlet weak var nameTextField: UITextField! // Text field for entering the name
    @IBOutlet weak var deviceTextField: UITextField! // Text field for entering the device
    @IBOutlet weak var setButton: UIButton! // Button to set the caller name and device
    
    var delegate : callerNameDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        self.view.backgroundColor = hexStringToUIColor(hex: "515A80")
    }
    
    private func setupUI() {
        nameLabel.text = "Name:" // Set the label text for name
        deviceLabel.text = "Device:" // Set the label text for device
        
        nameTextField.placeholder = "Enter name" // Set placeholder text for the name text field
        deviceTextField.placeholder = "Enter device" // Set placeholder text for the device text field
        
        setButton.setTitle("Set", for: .normal) // Set the button title
        setButton.setTitleColor(.white, for: .normal) // Set the text color of the button
        setButton.backgroundColor = .blue // Set the background color of the button
        setButton.layer.cornerRadius = setButton.bounds.height / 2 // Apply rounded corners to the button
    }
    
    @IBAction func setButtonPressed(_ sender: UIButton) {
        guard let name = nameTextField.text, let device = deviceTextField.text else {
            return
        }
        
        delegate?.callerName(cName: name, dName: device) // Call the delegate method to pass the caller name and device
        navigationController?.popToRootViewController(animated: true) // Pop back to the root view controller
    }
    
}

