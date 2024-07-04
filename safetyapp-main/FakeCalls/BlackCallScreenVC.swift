//
//  BlackCallScreenVC.swift
//  FakeCallPro
//
//  Created by Ankit Saxena on 05/03/19.
//  Copyright © 2019 Ankit Saxena. All rights reserved.
//

import UIKit

class BlackCallScreenVC: UIViewController {
    
    @IBOutlet weak var tipLabel: UILabel!
    
    var receivedSettings : [String : String]?
    var time = ""
    var timeInDouble = 0.0
    var timer : Timer!

    override func viewDidLoad() {
        super.viewDidLoad()
        timeDouble()
        tipLabel.text = "You will receive a call after \(timeInDouble) seconds. Don't lock the phone and Don't press the home Button."
        timer = Timer.scheduledTimer(withTimeInterval: timeInDouble, repeats: false, block: { (Timer) in
        self.performSegue(withIdentifier: "startCall", sender: self)
        })
    }
    

    
//    func timeDouble() -> Double{
//        if time == "3 Seconds Later"{
//            return 3
//        }
//
//        else if time == "10 Seconds Later"{
//            return 10
//        }
//
//        else if time == "30 Seconds Later"{
//            return 30
//        }
//
//        else if time == "1 Minute Later"{
//            return 60
//        }
//
//        else if time == "2 Minutes Later"{
//            return 120
//        }
//        else {
//            return 300
//        }
//
//    }
    
    func timeDouble() {
        switch time {
            
        case "3 Seconds Later":
            timeInDouble = 3
            
        case "10 Seconds Later":
            timeInDouble = 10
        
        case "30 Seconds Later":
            timeInDouble = 30
            
        case "1 Minute Later":
            timeInDouble = 60
            
        case "2 Minutes Later":
            timeInDouble = 120
            
        case "5 Minutes Later":
            timeInDouble = 300
            
        case "8 Minutes Later":
            timeInDouble = 480
            
        case "12 Minutes Later":
            timeInDouble = 720
            
        case "20 Minutes Later":
            timeInDouble = 1200
            
        case "30 Minutes Later":
            timeInDouble = 1800
            
        case "1 Hour Later":
            timeInDouble = 3600
            
        default:
            timeInDouble = 10
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "startCall"{
            let destinationVC = segue.destination as! CallStartedVC
            destinationVC.receivedSettings = receivedSettings
        }
    }


}
