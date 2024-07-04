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

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var deviceTextField: UITextField!
    
    var delegate : callerNameDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func setButtonPressed(_ sender: UIButton) {
        delegate?.callerName(cName: nameTextField.text!, dName: deviceTextField.text!)
        navigationController?.popToRootViewController(animated: true)
    }
    

}
