//
//  BarDetailViewController.swift
//  Bar Hopper
//
//  Created by Step Cannuscio on 12/10/18.
//  Copyright © 2018 Step Cannuscio. All rights reserved.
//

import UIKit
import GooglePlaces
import MapKit
import Contacts

class BarDetailViewController: UIViewController {
//
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var waitTimeLabel: UILabel!
    @IBOutlet weak var averageRatingLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var cancelButton: UIBarButtonItem!

    var bar: Bar!
    var reviews: Reviews!
    var photos: Photos!
    let regionDistance: CLLocationDistance = 750 // 750 meters, or about a half mile
    var locationManager: CLLocationManager!
    var currentLocation: CLLocation!
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //hide keyboard if we tap outside of a field
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
//        mapView.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        collectionView.delegate = self
        collectionView.dataSource = self
        imagePicker.delegate = self
        
        if bar == nil { // We are adding a new record, fields should be editable
            bar = Bar()
        }
        getLocation()
        
        //Add Bar Hopper logo to navigation bar
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 15, height: 15))
        imageView.contentMode = .scaleAspectFit
        let image = UIImage(named: "bar_hopper logo")
        imageView.image = image
        navigationItem.titleView = imageView
        
        
        reviews = Reviews()
        photos = Photos()
        
        let region = MKCoordinateRegion(center: bar.coordinate, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
        mapView.setRegion(region, animated: true)
        updateUserInterface()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reviews.loadData(bar: bar) {
            self.tableView.reloadData()
            if self.reviews.reviewArray.count > 0 {
                var total = 0
                for review in self.reviews.reviewArray {
                    total = total + review.rating
                }
                let average = Double(total) / Double(self.reviews.reviewArray.count)
                self.averageRatingLabel.text = "\(average.roundTo(places: 1))"
            } else {
                self.averageRatingLabel.text = "-.-"
            }
        }
    
        photos.loadData(bar: bar) {
            self.collectionView.reloadData()
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        bar.name = nameLabel.text!
        bar.address = addressLabel.text!
        switch segue.identifier ?? "" {
        case "AddReview":
            let navigationController = segue.destination as! UINavigationController
            let destination = navigationController.viewControllers.first as! ReviewTableViewController
            destination.bar = bar
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                tableView.deselectRow(at: selectedIndexPath, animated: true)
            }
        case "ShowReview":
            let destination = segue.destination as! ReviewTableViewController
            destination.bar = bar
            let selectedIndexPath = tableView.indexPathForSelectedRow!
            destination.review = reviews.reviewArray[selectedIndexPath.row]
        default:
            print("**** ERROR: Did not have a segue in SpotDetailViewController prepare(for segue)")
            
        }
    }
//
//    func disableTextEditing() {
//        nameField.backgroundColor = UIColor.clear
//        nameField.isEnabled = false
//        nameField.noBorder()
//        addressField.backgroundColor = UIColor.clear
//        addressField.isEnabled = false
//        addressField.noBorder()
//    }
    
    func saveCancelAlert(title: String, message: String, segueIdentifier: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save", style: .default) { (_) in
            self.bar.saveData { success in
                self.saveButton.title = "Done"
                self.cancelButton.title = ""
                self.navigationController?.setToolbarHidden(true, animated: true)
//                self.disableTextEditing()
                if segueIdentifier == "AddReview" {
                    self.performSegue(withIdentifier: segueIdentifier, sender: nil)
                } else {
                    self.cameraOrLibraryAlert()
                }
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }

    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(alertAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func updateUserInterface() {
        nameLabel.text = bar.name
        addressLabel.text = bar.address
        updateMap()
        
    }
    
    func updateMap() {
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotation(bar)
        mapView.setCenter(bar.coordinate, animated: true)
    }
    
    func leaveViewController() {
        let isPresentingInAddMode = presentingViewController is UINavigationController
        if isPresentingInAddMode {
            dismiss(animated: true, completion: nil)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    func cameraOrLibraryAlert() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { _ in
            self.accessCamera()
        }
        let photoLibraryAction = UIAlertAction(title: "Photo Library", style: .default) { _ in
            self.accessLibrary()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cameraAction)
        alertController.addAction(photoLibraryAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
        
    }
    
    
//
//    @IBAction func textFieldEditingChanged(_ sender: UITextField) {
//        saveButton.isEnabled = !(nameLabel.text == "")
//    }
//    @IBAction func textFieldReturnPressed(_ sender: UITextField) {
//        sender.resignFirstResponder()
//        bar.name = nameLabel.text!
//        bar.address = addressLabel.text!
//        updateUserInterface()
//    }
//
    //MARK: Actions
    
    @IBAction func photoButtonPressed(_ sender: UIButton) {
        if bar.documentID == "" {
            saveCancelAlert(title: "This Venue Has Not Been Saved", message: "You must save this venue before you can add a photo.", segueIdentifier: "AddPhoto")
        } else {
            cameraOrLibraryAlert()
        }
    }
    
  
    @IBAction func reviewButtonPressed(_ sender: UIButton) {
        if bar.documentID == "" {
            saveCancelAlert(title: "This Venue Has Not Been Saved", message: "You must save this venue before you can review it.", segueIdentifier: "AddReview")
        } else {
            performSegue(withIdentifier: "AddReview", sender: nil)
        }

    }
    
    

    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        bar.name = nameLabel.text!
        bar.address = addressLabel.text!
        bar.saveData { success in
            if success {
                self.leaveViewController()
            } else {
                print("*** ERROR. Couldn't leave this view controller b/c data wasn't saved")            }
        }
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        leaveViewController()
    }
}


extension BarDetailViewController: CLLocationManagerDelegate {
    
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
        guard bar.name == "" else {
            return
        }
        let geoCoder = CLGeocoder()
        var name = ""
        var address = ""
        currentLocation = locations.last
        bar.coordinate = currentLocation.coordinate
        geoCoder.reverseGeocodeLocation(currentLocation, completionHandler: {placemarks, error in
            if placemarks != nil {
                let placemark = placemarks?.last
                name = placemark?.name ?? "name unknown"
                //need to import Contacts to use this code:
                if let postalAddress = placemark?.postalAddress {
                    address = CNPostalAddressFormatter.string(from: postalAddress, style: .mailingAddress)
                }
            } else {
                print("ERROR retrieving code - \(error!.localizedDescription)")
            }
            self.bar.name = name
            self.bar.address = address
            self.updateUserInterface()
            
        })
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get user location")
    }
}

extension BarDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reviews.reviewArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReviewCell", for: indexPath) as! BarReviewsTableViewCell
        cell.review = reviews.reviewArray[indexPath.row]
        return cell
    }
}

extension BarDetailViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.photoArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! BarPhotosCollectionViewCell
        cell.photo = photos.photoArray[indexPath.row]
        return cell
        
    }
}

extension BarDetailViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let photo = Photo()
        photo.image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        
        dismiss(animated: true) {
            photo.saveData(bar: self.bar) { (success) in
                if success {
                    self.photos.photoArray.append(photo)
                    self.collectionView.reloadData()
                }
            }
            
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func accessLibrary() {
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    func accessCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.sourceType = .camera
            present(imagePicker, animated: true, completion: nil)
        } else {
            showAlert(title: "Camera Not Available", message: "There is no camera available on this device")
        }
    }
}
