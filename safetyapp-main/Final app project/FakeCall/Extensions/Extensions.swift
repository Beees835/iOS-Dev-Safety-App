//
//  Extensions.swift
//  FakeCallPro
//
//  Created by Ankit Saxena on 21/06/19.
//  Copyright © 2019 Ankit Saxena. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    
    @IBInspectable var roundUpper : Bool{
        get{
            return true
        }
        set{
            self.layer.cornerRadius = 15.0
            self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            self.clipsToBounds = true        }
    }
    
    @IBInspectable var roundLower : Bool{
        get{
            return true
        }
        set{
            self.layer.cornerRadius = 15.0
            self.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
            self.clipsToBounds = true
            
        }
    }
    
    @IBInspectable var enableShadow : Bool{
        get {
            return true
        }
        set{
            self.layer.shadowColor = UIColor.black.cgColor
            self.layer.shadowOpacity = 1
            self.layer.shadowOffset = CGSize(width: 10.0, height: 10.0)
            self.layer.shadowRadius = 20.0
        }
    }
    
}


extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
