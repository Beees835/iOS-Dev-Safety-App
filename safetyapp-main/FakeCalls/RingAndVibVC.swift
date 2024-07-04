//
//  RingAndVibVC.swift
//  FakeCallPro
//
//  Created by Ankit Saxena on 25/02/19.
//  Copyright © 2019 Ankit Saxena. All rights reserved.
//

import UIKit
import AVFoundation


protocol SelectRingDelegate {
    func selectedRing(ring : String, eSound : Bool, eVibration : Bool)
}

class RingAndVibVC: UITableViewController {

    @IBOutlet weak var soundSwitch: UISwitch!
    @IBOutlet weak var vibrationSwitch: UISwitch!
    
    var audioPlayer : AVAudioPlayer!
    var currentIndex = 0
    var ringArray = ["Opening", "Reflection", "Marimba", "Xylophone", "Apex", "By The Seaside", "Piano Riff", "Sencha", "Silk", "Strum", "Time Passing", "Night Owl", "Old Phone"]

    var delegate : SelectRingDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
  
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        if self.isMovingFromParent{
            print("Sound is \(soundSwitch.isOn), Vib is \(vibrationSwitch.isOn)")
            delegate?.selectedRing(ring: ringArray[currentIndex], eSound: soundSwitch.isOn, eVibration: vibrationSwitch.isOn)
        }
    }

    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1{
            currentIndex = indexPath.row
            playSound(with: currentIndex)
        }
        
    }
    
    
    func playSound(with ringIndex : Int){
        let soundURl = Bundle.main.url(forResource: ringArray[ringIndex], withExtension: "mp3")
        do{
            audioPlayer = try AVAudioPlayer(contentsOf: soundURl!)
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default)
        }
            
        catch{
            print(error)
        }
        
        //Playing Audio
        audioPlayer.play()
        
        }
        
}

