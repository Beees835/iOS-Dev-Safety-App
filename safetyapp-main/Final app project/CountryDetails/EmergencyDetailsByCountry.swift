//
//  EmergencyDetailsByCountry.swift
//  Final app project
//
//  Created by Beees on 17/5/2023.
//

import UIKit

// JSON strcut for desired data to fetch
struct Country {
    let code: String
    let fire: String
    let police: String
    let name: String
    let medical: String
}

// UI elements settings

class CountryTableViewCell: UITableViewCell {
    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let codeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let emergencyLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // Add subviews and set up constraints
        contentView.addSubview(nameLabel)
        contentView.addSubview(codeLabel)
        contentView.addSubview(emergencyLabel)
        
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            codeLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            codeLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            
            emergencyLabel.topAnchor.constraint(equalTo: codeLabel.bottomAnchor, constant: 4),
            emergencyLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            emergencyLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with country: Country) {
        // Configure the cell with country data
        nameLabel.text = country.name
        codeLabel.text = "Country Code: \(country.code)"
        emergencyLabel.text = "Emergency Numbers: Fire: \(country.fire), Police: \(country.police), Medical: \(country.medical)"
    }
    
}

class EmergencyDetailsByCountryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var countries: [Country] = []
    var filteredCountries: [Country] = []
    var isSearching = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up table view and search bar delegates
        tableView.dataSource = self
        tableView.delegate = self
        searchBar.delegate = self
        
        // Register table view cell class
        tableView.register(CountryTableViewCell.self, forCellReuseIdentifier: "CountryCell")
        
        // Set background color
        self.view.backgroundColor = hexStringToUIColor(hex: "515A80")
        
        // Fetch JSON data
        fetchJSONData()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Hide navigation bar and disable large titles
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Show navigation bar
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    // Fetchig JSON data
    // Source: W5
    func fetchJSONData() {
        guard let url = URL(string: "https://favmaps.es/emergency/numbers/") else {
            print("Invalid URL")
            return
        }
        
        let session = URLSession.shared
        
        // Error catching 
        let task = session.dataTask(with: url) { [weak self] (data, response, error) in
            if let error = error {
                print("Error: \(error)")
                return
            }
            
            guard let data = data else {
                print("No data received")
                return
            }
            
            // Fecthing the content we want then append into array list we created
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                
                if let content = json?["content"] as? [[String: Any]] {
                    for item in content {
                        if let code = item["code"] as? String,
                           let fire = item["fire"] as? String,
                           let police = item["police"] as? String,
                           let name = item["name"] as? String,
                           let medical = item["medical"] as? String {
                            let country = Country(code: code, fire: fire, police: police, name: name, medical: medical)
                            self?.countries.append(country)
                        }
                    }
                    // Update UI in table view
                    DispatchQueue.main.async {
                        self?.tableView.reloadData()
                    }
                }
            } catch {
                print("Error parsing JSON: \(error)")
            }
        }
        task.resume()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSearching ? filteredCountries.count : countries.count
    }
    
    // Configure table view styles
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CountryCell", for: indexPath) as! CountryTableViewCell
        
        let country = isSearching ? filteredCountries[indexPath.row] : countries[indexPath.row]
        cell.configure(with: country)
        
        return cell
    }
    
    
    // Configure search bar
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            isSearching = false
            filteredCountries = []
        } else {
            isSearching = true
            filteredCountries = countries.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        }
        tableView.reloadData()
    }
}
