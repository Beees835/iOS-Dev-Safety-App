//
//  TestMapViewController.swift
//  Final app project
//
//  Created by Beees on 8/5/2023.
//

import UIKit
import MapKit
import CoreLocation

class TestMapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    let locationManager = CLLocationManager()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.showsUserLocation = true
        
        if CLLocationManager.locationServicesEnabled() {
           // continue to implement here
        } else {
           // Do something to let users know why they need to turn it on.
        }
        
        
        // Do any additional setup after loading the view.
    }
    
    
    func checkAuthorizationStatus() {
      switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse: break
        case .denied: break
        case .notDetermined: break
        case .restricted: break
        case .authorizedAlways: break
      }
    }
    
   
    @IBAction func getCurrentLocation(_ sender: Any) {
        if CLLocationManager.locationServicesEnabled() {
            
           // continue to implement here
        } else {
           // Do something to let users know why they need to turn it on.
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
