//
//  FilterViewController.swift
//  Bar Hopper
//
//  Created by Step Cannuscio on 12/11/18.
//  Copyright © 2018 Step Cannuscio. All rights reserved.
//

import UIKit
import CoreLocation

class FilterViewController: UIViewController {

    @IBOutlet weak var sortButton: UIButton!
    @IBOutlet weak var waitTimeSegment: UISegmentedControl!
    @IBOutlet weak var ratingSegment: UISegmentedControl!
    @IBOutlet weak var distanceSegment: UISegmentedControl!
    @IBOutlet weak var filterView: UIView!
    
    var bars: Bars!
    var locationManager: CLLocationManager!
    var currentLocation: CLLocation!
    
    var currentSegment = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        getLocation()
       
        
        
        filterView.layer.cornerRadius = filterView.frame.size.width / 12
  

       
    }
  
    
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(alertAction)
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func distanceSegmentChanged(_ sender: UISegmentedControl) {
        if distanceSegment.selectedSegmentIndex > 0 {
            ratingSegment.isEnabled = false
            waitTimeSegment.isEnabled = false
            currentSegment = 0
        } else {
            ratingSegment.isEnabled = true
            waitTimeSegment.isEnabled = true
        }
    }
    
    @IBAction func ratingSegmentChanged(_ sender: UISegmentedControl) {
        if ratingSegment.selectedSegmentIndex > 0 {
            distanceSegment.isEnabled = false
            waitTimeSegment.isEnabled = false
            currentSegment = 1
        } else {
            distanceSegment.isEnabled = true
            waitTimeSegment.isEnabled = true
        }
    }
    
    @IBAction func waitTimeSegmentChang(_ sender: UISegmentedControl) {
        if waitTimeSegment.selectedSegmentIndex > 0 {
            ratingSegment.isEnabled = false
            distanceSegment.isEnabled = false
            currentSegment = 2
        } else {
            distanceSegment.isEnabled = true
            ratingSegment.isEnabled = true
        }
    }
    @IBAction func sortButtonPressed(_ sender: UIButton) {
        switch currentSegment {
        case 0:
            print("distance segment")
            if distanceSegment.selectedSegmentIndex == 1 {
                bars.barArray.sort(by: {$0.location.distance(from: currentLocation) < $1.location.distance(from: currentLocation)} )
            } else if distanceSegment.selectedSegmentIndex == 2 {
                 bars.barArray.sort(by: {$0.location.distance(from: currentLocation) > $1.location.distance(from: currentLocation)} )
            }
        case 1:
            print("rating segment")
            if ratingSegment.selectedSegmentIndex == 1 {
                bars.barArray.sort(by: {$0.averageRating < $1.averageRating})
            } else if ratingSegment.selectedSegmentIndex == 2 {
                bars.barArray.sort(by: {$0.averageRating > $1.averageRating})
            }
        case 2:
//            print(bars.barArray[0])
            if waitTimeSegment.selectedSegmentIndex == 1 {
                bars.barArray.sort(by: {$0.waitTime < $1.waitTime})
            } else if waitTimeSegment.selectedSegmentIndex == 2 {
                 bars.barArray.sort(by: {$0.waitTime > $1.waitTime})
            }
            print(bars.barArray[0].name)
        default:
            print("🍆Error should not have gotten to here")
        }

        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "load"), object: nil)
      
        dismiss(animated: true, completion: nil)
        
    }
    
   
    
    
}


extension FilterViewController: CLLocationManagerDelegate {
    
    func getLocation() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
    }
    
    func showAlertToPrivacySettings(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {
            print("Something went wrong getting the UIApplication.openSettingsURLString")
            return
        }
        
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { value in
            UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
        }
        
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(settingsAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func handleLocationAuthorizationStatus(status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            locationManager.requestAlwaysAuthorization()
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.requestLocation()
        case .denied:
            showAlert(title: "User has not authorized location services", message: "Select 'Settings' below to open device settings and enable location services for this app.")
        case .restricted:
            showAlert(title: "Location services denied", message: "It may be that parental controls are restriction location usage in this app.")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        handleLocationAuthorizationStatus(status: status)
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last
        print("Current location is \(currentLocation.coordinate.longitude), \(currentLocation.coordinate.latitude)")
//        sortBasedOnSegmentPressed()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get user location")
    }
}
