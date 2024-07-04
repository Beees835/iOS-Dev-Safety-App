//
//  SOSViewController.swift
//  Final app project
//
//  Created by Beees on 18/5/2023.
//

import UIKit
import AVFoundation
import CoreData
import CoreLocation
import MapKit

class SOSViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    let locationManager = CLLocationManager()
    var emergencyContactNumber: String = ""
    var mapView: MKMapView!
    
    @IBOutlet weak var sosButton: UIButton!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var mapTypeSegmentedControl: UISegmentedControl!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapTypeSegmentedControl.selectedSegmentIndex = 0
        fetchEmergencyContact()
        
        // UI design part
        setupLocationManager()
        setupMapView()
        setupLocationLabel()
        setupSegmentedControl()
        setupSOSButton()
        self.title = "SOS"
        
        // Map view basic setup
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        self.hideKeyboardWhenTappedAround()
        
        self.view.backgroundColor = hexStringToUIColor(hex: "515A80")
    }
    
    /*
     This part os for UI set up
     */
    
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.requestWhenInUseAuthorization()
    }
    
    // UI setting for map view
    
    func setupMapView() {
        mapView = MKMapView()
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.delegate = self
        mapView.showsUserLocation = true
        view.addSubview(mapView)
        
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            mapView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            mapView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            mapView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.3)
        ])
    }
    
    func setupLocationLabel() {
        locationLabel.translatesAutoresizingMaskIntoConstraints = false
        locationLabel.numberOfLines = 0
        locationLabel.textAlignment = .center
        locationLabel.textColor = .black
        locationLabel.font = UIFont.systemFont(ofSize: 18)
        locationLabel.backgroundColor = UIColor.systemGray5.withAlphaComponent(0.3)
        
        NSLayoutConstraint.activate([
            locationLabel.topAnchor.constraint(equalTo: mapView.bottomAnchor, constant: 20),
            locationLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            locationLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
        ])
    }

    func setupSegmentedControl() {
        _ = ["Standard", "Hybrid"]
        mapTypeSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        mapTypeSegmentedControl.selectedSegmentIndex = 0
        mapTypeSegmentedControl.addTarget(self, action: #selector(mapTypeChanged), for: .valueChanged)
        
        // UI Design for Segmented Control
        mapTypeSegmentedControl.backgroundColor = .systemBackground
        mapTypeSegmentedControl.selectedSegmentTintColor = .systemBlue
        mapTypeSegmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        mapTypeSegmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.systemBlue], for: .normal)
        
        self.view.addSubview(mapTypeSegmentedControl)
        
        NSLayoutConstraint.activate([
            mapTypeSegmentedControl.topAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: 20),
            mapTypeSegmentedControl.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            mapTypeSegmentedControl.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
        ])
    }
    
    func setupSOSButton() {
        sosButton.translatesAutoresizingMaskIntoConstraints = false
        sosButton.setTitle("SOS", for: .normal)
        
        NSLayoutConstraint.activate([
            sosButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            sosButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            sosButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            sosButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    /*
     This part is for all the methods that required to control in this page 
     */
    
    @IBAction func mapTypeChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            mapView.mapType = .standard
        case 1:
            mapView.mapType = .hybrid
        default:
            break
        }
    }
    
    
    // Using core location to access to user's current location
        // Using switch case to catch errors
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            showAlertToOpenSettings()
        case .authorizedAlways, .authorizedWhenInUse:
            manager.startUpdatingLocation()
        @unknown default:
            fatalError("A new case was added that we need to handle")
        }
    }
    
    // Location manager
    // Source W7
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            let geocoder = CLGeocoder()
            manager.stopUpdatingLocation()
            render(location)
            geocoder.reverseGeocodeLocation(location) { [weak self] (placemarks, error) in
                if error == nil {
                    if let placemark = placemarks?[0] {
                        var addressString : String = ""
                        if let subLocality = placemark.subLocality {
                            addressString = addressString + subLocality + ", "
                        }
                        if let thoroughfare = placemark.thoroughfare {
                            addressString = addressString + thoroughfare + ", "
                        }
                        if let locality = placemark.locality {
                            addressString = addressString + locality + ", "
                        }
                        if let country = placemark.country {
                            addressString = addressString + country
                        }
                        DispatchQueue.main.async {
                            self?.locationLabel.text = "Latitude: \(location.coordinate.latitude)\nLongtitude: \(location.coordinate.longitude)\nAddress: \(addressString)"
                        }
                    }
                }
            }
        }
    }
    
    // redering the location
    func render(_ location: CLLocation) {
        let coordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(region, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Handle error
        print("Failed to get location, error: \(error)")
    }
    
    // Producing accurate address of users' current location 
    func reverseGeocode(_ location: CLLocation) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { [weak self] (placemarks, error) in
            if error == nil {
                if let placemark = placemarks?[0] {
                    var addressString : String = ""
                    if let subLocality = placemark.subLocality {
                        addressString = addressString + subLocality + ", "
                    }
                    if let thoroughfare = placemark.thoroughfare {
                        addressString = addressString + thoroughfare + ", "
                    }
                    if let locality = placemark.locality {
                        addressString = addressString + locality + ", "
                    }
                    if let country = placemark.country {
                        addressString = addressString + country
                    }
                    DispatchQueue.main.async {  // ensure UI update runs on main thread
                        self?.locationLabel.text = "Location: \(location.coordinate.latitude), \(location.coordinate.longitude)\nAddress: \(addressString)"
                    }
                }
            }
        }
    }
    
    // Asking user to open setting if access denied.
    func showAlertToOpenSettings() {
        let alertController = UIAlertController(title: "Location Access Disabled", message: "In order to fetch your current location, please open this app's settings and set location access to 'While Using the App'.", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let openAction = UIAlertAction(title: "Open Settings", style: .default) { (action) in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        alertController.addAction(cancelAction)
        alertController.addAction(openAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    // Accessing to the user's ER contact list and take the top one to call
    func fetchEmergencyContact() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainerEmergencyContact.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "EmergencyContact")
        
        do {
            let contacts = try managedContext.fetch(fetchRequest)
            if let contact = contacts.first {
                emergencyContactNumber = contact.value(forKeyPath: "phoneNumber") as? String ?? ""
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    // This will call the person phone number on the very top of the list in ER contact that user has set up
    // Call function not avliable in simulator
    // Source: https://stackoverflow.com/questions/27259824/calling-a-phone-number-in-swift
    @IBAction func sosTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: "Emergency", message: "Are you sure you want to call your emergency contact?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
            guard let url = URL(string: "tel://\(self.emergencyContactNumber)") else {
                return
            }
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                print(self.emergencyContactNumber) // printing out emergecy contact os that it shows which number we are taking
            }
        }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
}
