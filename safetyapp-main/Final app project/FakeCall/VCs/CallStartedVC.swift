//
//  CallStartedVC.swift
//  FakeCallPro
//
//  Created by Ankit Saxena on 03/03/19.
//  Copyright © 2019 Ankit Saxena. All rights reserved.
//

import UIKit
import AVFoundation

class CallStartedVC: UIViewController {

    @IBOutlet weak var callerName: UILabel!
    @IBOutlet weak var deviceName: UILabel!
    
    var receivedSettings : [String : String]?
    var audioPlayer : AVAudioPlayer!
    var ring = "Opening"
    var timer : Timer!
    var enableSound  = true
    var enableVibration = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkCallerName()
        checkVibrationAndSound()
        playSound()
    }
    
    func checkCallerName(){
        if let callerName = receivedSettings?["defCaller"]{
            getCallerLabel(cLabel: callerName)
            ring = receivedSettings?["defRing"] ?? "Opening"
        }
        else{
            callerName.text = "Ashish def"
        }
    }
    
    func checkVibrationAndSound(){
        if receivedSettings!["eVibration"] == "false"{
            enableVibration = false
        }
        if receivedSettings!["eSound"] == "false"{
            enableSound = false
        }
    }
    
    func playSoundVibration(){
        if enableSound == true{
            audioPlayer.play()
        }
        if enableVibration == true{
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        }
    }
    
    //MARK: Playoing Sound Function
    func playSound(){
        let soundURl = Bundle.main.url(forResource: ring, withExtension: "mp3")
        do{
            audioPlayer = try AVAudioPlayer(contentsOf: soundURl!)
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default)
        }
            
        catch{
            print(error)
        }
        //Playing Audio
        playSoundVibration()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { (Timer) in
            self.playSoundVibration()
        }
        
    }
    
    func getCallerLabel(cLabel: String) {
        callerName.text = cLabel
        deviceName.text = receivedSettings!["dName"]!
    }
    
    
    //MARK: Call Accept and Decline Funtions
    
    @IBAction func declineButtonPressed(_ sender: UIButton) {
        audioPlayer.stop()
        timer.invalidate()
        UIControl().sendAction(#selector(NSXPCConnection.suspend),
                               to: UIApplication.shared, for: nil)
        self.presentingViewController?.presentingViewController?.dismiss(animated: false, completion: nil)
    }
    
    @IBAction func acceptButtonPressed(_ sender: UIButton) {
        audioPlayer.stop()
        timer.invalidate()
        performSegue(withIdentifier: "callPicked", sender: self)
    }
    
    //Sending Default Settings to the next Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "callPicked"{
            let destinationVC = segue.destination as! CallAcceptedVC
            destinationVC.receivedSettings = receivedSettings
        }
    }

}
