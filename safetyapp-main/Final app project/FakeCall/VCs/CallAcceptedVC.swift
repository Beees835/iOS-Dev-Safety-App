//
//  CallAcceptedVC.swift
//  FakeCallPro
//
//  Created by Ankit Saxena on 05/03/19.
//  Copyright © 2019 Ankit Saxena. All rights reserved.
//

import UIKit
import AVFoundation

class CallAcceptedVC: UIViewController {

    @IBOutlet weak var callerNameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    var seconds : Int = 0
    var minutes : Int = 0
    var timer : Timer!
    var secText = "", minText = ""
    var selectedVoice = "voice1"
    
    var receivedSettings : [String : String]?
    var buttonPressedCount = 0
    
    var audioPlayer : AVAudioPlayer!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        selectVoice()
        playSound()
        let device = UIDevice.current
        device.isProximityMonitoringEnabled = true
        setCallerName()
        
        secText = String.init(format: "%02d", seconds)
        minText = String.init(format: "%02d", minutes)
        timeLabel.text = "\(minText) : \(secText)"
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (Timer) in
            self.updateSec()
        })
        
    }
    
    func selectVoice(){
        if let receivedVoice = receivedSettings?["defVoice"]{
            selectedVoice = receivedVoice
        }
    }
    
    func playSound(){
        print("Selected Voice is \(selectedVoice)")
        let soundURl = Bundle.main.url(forResource: "\(selectedVoice.lowercased())", withExtension: "mp3")
        do{
            audioPlayer = try AVAudioPlayer(contentsOf: soundURl!)
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playAndRecord, mode: AVAudioSession.Mode.default)
        }
            
        catch{
            print(error)
        }
        print("playing Sound")
        audioPlayer.play()
    }
    
    func setCallerName(){
        if let callername = receivedSettings?["defCaller"]{
            callerNameLabel.text = callername
        }
        else{
            callerNameLabel.text = "Ashish def"
        }
    }

    func updateSec(){
        if seconds > 59{
            seconds = 0
            updateMins()
        }
        secText = String.init(format: "%02d", seconds)
        timeLabel.text = "\(minText) : \(secText)"
        seconds = seconds + 1
    }
    
    func updateMins(){
        if minutes > 59{
            minutes = 0
        }
        minutes = minutes + 1
        minText = String.init(format: "%02d", minutes)
        timeLabel.text = "\(minText) : \(secText)"
    }

    @IBAction func endButtonPressed(_ sender: UIButton) {
        buttonPressedCount = buttonPressedCount + 1
        timer.invalidate()
        timeLabel.text = "call ended"
        buttonPressedCount == 1 ? callEnd(with: 2) : callEnd()
        print("Timer ")
    }
    
    func callEnd(with wTime : Double = 0){
        timer = Timer.scheduledTimer(withTimeInterval: wTime, repeats: true, block: { (Timer) in
            print("Call ENDED")
            self.buttonPressedCount = 0
            UIControl().sendAction(#selector(NSXPCConnection.suspend),
                                   to: UIApplication.shared, for: nil)
            self.presentingViewController?.presentingViewController?.presentingViewController?.dismiss(animated: false, completion: nil)
            Timer.invalidate()
        })
    }
}
