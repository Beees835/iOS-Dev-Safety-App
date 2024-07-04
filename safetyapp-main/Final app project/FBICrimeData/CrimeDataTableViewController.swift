//
//  CrimeDataTableViewController.swift
//  Final app project
//
//  Created by Beees on 22/5/2023.
//

import UIKit
import Charts

struct CrimeData: Decodable {
    let year: Int
    let population: String
    let violent_crime: String
    let homicide: String
    let rape_revised: String?
    let robbery: String
    let aggravated_assault: String
    let property_crime: String
    let burglary: String
    let larceny: String
    let motor_vehicle_theft: String
    let arson: String
    
    private enum CodingKeys: String, CodingKey {
        case year
        case population
        case violent_crime
        case homicide
        case rape_revised
        case robbery
        case aggravated_assault
        case property_crime
        case burglary
        case larceny
        case motor_vehicle_theft
        case arson
    }
}

class CrimeDataTableViewController: UITableViewController {

    var urlStr: String?
    var crimeDataArray = [CrimeData]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.rowHeight = 550
        fetchData()
        self.hideKeyboardWhenTappedAround() 
    }

    private func fetchData() {
        guard let urlStr = urlStr, let url = URL(string: urlStr) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        let task = URLSession.shared.dataTask(with: request) { [weak self] (data, response, error) in
            if let error = error {
                print("Error: \(error)")
            } else if let data = data {
                do {
                    if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                        DispatchQueue.main.async {
                            self?.presentAlert(title: "Error", message: "Received invalid status code: \(httpResponse.statusCode)")
                        }
                        return
                    }

                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    if let array = json as? [[String: Any]] {
                        for item in array {
                            guard let year = item["year"] as? Int,
                                  let population = item["population"] as? String,
                                  let violentCrime = item["violent_crime"] as? String,
                                  let homicide = item["homicide"] as? String,
                                  let rapeRevised = item["rape_revised"] as? String,
                                  let robbery = item["robbery"] as? String,
                                  let aggravatedAssault = item["aggravated_assault"] as? String,
                                  let propertyCrime = item["property_crime"] as? String,
                                  let burglary = item["burglary"] as? String,
                                  let larceny = item["larceny"] as? String,
                                  let motorVehicleTheft = item["motor_vehicle_theft"] as? String,
                                  let arson = item["arson"] as? String else {
                                    continue
                            }

                            let crimeData = CrimeData(year: year, population: population, violent_crime: violentCrime, homicide: homicide, rape_revised: rapeRevised, robbery: robbery, aggravated_assault: aggravatedAssault, property_crime: propertyCrime, burglary: burglary, larceny: larceny, motor_vehicle_theft: motorVehicleTheft, arson: arson)
                            self?.crimeDataArray.append(crimeData)
                        }
                        DispatchQueue.main.async {
                            self?.tableView.reloadData()
                        }
                    }
                } catch {
                    DispatchQueue.main.async {
                        self?.presentAlert(title: "Error", message: "Failed to parse data.")
                    }
                }
            }
        }
        task.resume()
    }

    // MARK: - TableView DataSource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return crimeDataArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell  {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "crimeDataCell")
        
        let crimeData = crimeDataArray[indexPath.row]
        
        let cellText = """
            Year: \(crimeData.year)
            Population: \(crimeData.population)
            Violent Crime: \(crimeData.violent_crime)
            Homicide: \(crimeData.homicide)
            Rape Revised: \(crimeData.rape_revised)
            Robbery: \(crimeData.robbery)
            Aggravated Assault: \(crimeData.aggravated_assault)
            Property Crime: \(crimeData.property_crime)
            Burglary: \(crimeData.burglary)
            Larceny: \(crimeData.larceny)
            Motor Vehicle Theft: \(crimeData.motor_vehicle_theft)
            Arson: \(crimeData.arson)
        """
        
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.text = cellText
        
        return cell
    }

    func presentAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
