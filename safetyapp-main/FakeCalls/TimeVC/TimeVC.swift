//
//  TimeVC.swift
//  FakeCallPro
//
//  Created by Ankit Saxena on 25/02/19.
//  Copyright © 2019 Ankit Saxena. All rights reserved.
//

import UIKit

protocol selectTimeDelegate {
    func timeSelected(sTime : String)
}

class TimeVC: UITableViewController {

    @IBOutlet var timeTableView: UITableView!
    
    var timeArray = ["3 Seconds Later", "10 Seconds Later", "30 Seconds Later", "1 Minute Later", "2 Minutes Later", "5 Minutes Later", "8 Minutes Later", "12 Minutes Later", "20 Minutes Later", "30 Minutes Later", "1 Hour Later"]
    var delegate : selectTimeDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "timeCell", for: indexPath)
        cell.textLabel?.text = timeArray[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return timeArray.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("selected\(indexPath.row)")
        let cell = timeTableView.cellForRow(at: indexPath)
        cell?.accessoryType = .checkmark
        delegate?.timeSelected(sTime: timeArray[indexPath.row])
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        print("Deselected\(indexPath.row)")
        let cell = timeTableView.cellForRow(at: indexPath)
        cell?.accessoryType = .none
    }

}
