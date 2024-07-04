//
//  NationalCrimeViewController.swift
//  Final app project
//
//  Created by Beees on 22/5/2023.
//

import UIKit

class NationalCrimeViewController: UIViewController, UITextFieldDelegate {
    
    let apiKey = "iiHnOKfno2Mgkt5AynpvPpUQTEyxE77jo1RU8PIv"
    
    @IBOutlet weak var startYearTextField: UITextField!
    @IBOutlet weak var endYearTextField: UITextField!
    @IBOutlet weak var fetchDataButton: UIButton!
    @IBOutlet weak var viewChartButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // UI Setup
        setupUI()
        self.hideKeyboardWhenTappedAround()
        self.view.backgroundColor = hexStringToUIColor(hex: "515A80")
    }
    
    private func setupUI() {
        // Set up UI elements
        startYearTextField.delegate = self
        startYearTextField.attributedPlaceholder = NSAttributedString(string: "Start Year",
                                                                      attributes: [NSAttributedString.Key.foregroundColor: UIColor.black])
        endYearTextField.delegate = self
        endYearTextField.attributedPlaceholder = NSAttributedString(string: "End Year",
                                                                    attributes: [NSAttributedString.Key.foregroundColor: UIColor.black])
        
        startYearTextField.borderStyle = .none
        endYearTextField.borderStyle = .none
        
        createBottomLine(for: startYearTextField)
        createBottomLine(for: endYearTextField)
        
        fetchDataButton.setTitle("Get Data", for: .normal)
        viewChartButton.setTitle("Get Charts", for: .normal)
        
        fetchDataButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        viewChartButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        // create a vertical stack view
        let stackView = UIStackView(arrangedSubviews: [startYearTextField, endYearTextField, fetchDataButton, viewChartButton])
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.spacing = 25
        
        // add the stack view to super view (i.e. self.view)
        self.view.addSubview(stackView)
        
        // set the constraints for stack view
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ])
    }
        
    private func createBottomLine(for textField: UITextField) {
        let lineView = UIView()
        lineView.translatesAutoresizingMaskIntoConstraints = false
        lineView.backgroundColor = .black
        textField.addSubview(lineView)
        
        NSLayoutConstraint.activate([
            lineView.leadingAnchor.constraint(equalTo: textField.leadingAnchor),
            lineView.trailingAnchor.constraint(equalTo: textField.trailingAnchor),
            lineView.bottomAnchor.constraint(equalTo: textField.bottomAnchor),
            lineView.heightAnchor.constraint(equalToConstant: 1)
        ])
    }


    @IBAction func fetchDataButtonTapped(_ sender: Any) {
        fetchData()
    }
    
    @IBAction func viewInChart(_ sender: Any) {
        guard let startYearText = startYearTextField.text,
              let endYearText = endYearTextField.text,
              let startYear = Int(startYearText),
              let endYear = Int(endYearText) else {
            presentAlert(title: "Input Error", message: "Invalid input. Please input a valid number.")
            return
        }
        
        if startYearText.count < 4 || endYearText.count < 4 {
            presentAlert(title: "Input Error", message: "Invalid input. Please input a valid year.")
            return
        }
        
        if startYear > endYear {
            presentAlert(title: "Logic error", message: "Invalid input. Start year cannot be greater than end year.")
            return
        }
        
        if startYear > 2020 || endYear > 2020 {
            presentAlert(title: "EndYear exceed datasets range", message: "The year cannot be greater than 2020. FBI doesn't support any data after 2020.")
            return
        }
        
        let urlStr = "https://api.usa.gov/crime/fbi/cde/estimate/national?from=\(startYear)&to=\(endYear)&API_KEY=iiHnOKfno2Mgkt5AynpvPpUQTEyxE77jo1RU8PIv"
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let crimeDataChartViewController = storyboard.instantiateViewController(identifier: "CrimeDataChartViewController") as? CrimeDataChartViewController else { return }
        
        crimeDataChartViewController.urlStr = urlStr
        
        crimeDataChartViewController.fetchData()
        
        navigationController?.pushViewController(crimeDataChartViewController, animated: true)
    }
    
    // Fetch data from FBI API
    // taking start to end year to show crime data
    private func fetchData() {
        guard let startYearText = startYearTextField.text,
              let endYearText = endYearTextField.text,
              let startYear = Int(startYearText),
              let endYear = Int(endYearText) else {
            presentAlert(title: "Input Error", message: "Please make sure to input valid start and end years.")
            return
        }
        
        if startYearText.count < 4 || endYearText.count < 4 {
            presentAlert(title: "Input Error", message: "Invalid input. Please input a valid year.")
            return
        }
        
        if startYear > endYear {
            presentAlert(title: "Logic error", message: "Invalid input. Start year cannot be greater than end year.")
            return
        }
        
        if startYear > 2020 || endYear > 2020 {
            presentAlert(title: "EndYear exceed datasets range", message: "The year cannot be greater than 2020. FBI doesn't support any data after 2020.")
            return
        }
        
        
        let urlStr = "https://api.usa.gov/crime/fbi/cde/estimate/national?from=\(startYear)&to=\(endYear)&API_KEY=\(apiKey)"
        
        // Check if the topViewController is already an instance of CrimeDataTableViewController
        if let topViewController = navigationController?.topViewController,
           topViewController is CrimeDataTableViewController {
            // If it is, update the urlStr
            (topViewController as! CrimeDataTableViewController).urlStr = urlStr
        } else {
            // If it's not, then instantiate and push the new CrimeDataTableViewController
            guard let crimeDataTableViewController = storyboard?.instantiateViewController(identifier: "CrimeDataTableViewController") as? CrimeDataTableViewController else { return }
            crimeDataTableViewController.urlStr = urlStr
            navigationController?.pushViewController(crimeDataTableViewController, animated: true)
        }
    }
    
    func presentAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func showErrorMessage(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
