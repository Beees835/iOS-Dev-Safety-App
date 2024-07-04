//
//  SetVoice.swift
//  FakeCallPro
//
//  Created by Ankit Saxena on 26/02/19.
//  Copyright © 2019 Ankit Saxena. All rights reserved.
//

import UIKit

protocol selectVoiceDelegate {
    func voiceSelected(sVoice : String)
}

class SetVoice: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var setVoiceTable: UITableView!
    var voiceArray = ["Voice1", "Voice2", "Voice3"]
    var delegate : selectVoiceDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setVoiceTable.delegate = self
        setVoiceTable.dataSource = self
        setVoiceTable.tableFooterView = UIView()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "voiceCell", for: indexPath)
        cell.textLabel?.text = voiceArray[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return voiceArray.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.voiceSelected(sVoice: voiceArray[indexPath.row])
    }
}
