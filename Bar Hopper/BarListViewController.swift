//
//  BarListViewController.swift
//  Bar Hopper
//
//  Created by Step Cannuscio on 12/10/18.
//  Copyright © 2018 Step Cannuscio. All rights reserved.
//
import UIKit
import CoreLocation
import Firebase
import FirebaseUI
import GoogleSignIn
import FacebookLogin
import FacebookCore
import FBSDKLoginKit
import GooglePlaces


class BarListViewController: UIViewController, BarTableViewCellDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var newIndexPath = 0
    
    var bar: Bar!
    var bars: Bars!
    var authUI: FUIAuth!
//    var barUser: barUser!
    var locationManager: CLLocationManager!
    var currentLocation: CLLocation!
//    @IBOutlet weak var sortSegmentedControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
   
        
      
        
        authUI = FUIAuth.defaultAuthUI()
        authUI?.delegate = self
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.isHidden = true
        
        if bar == nil {
            bar = Bar()
        }
        NotificationCenter.default.addObserver(self, selector: #selector(loadList), name: NSNotification.Name(rawValue: "load"), object: nil)
        
        //Add Bar Hopper logo to navigation bar
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 15, height: 15))
        imageView.contentMode = .scaleAspectFit
        let image = UIImage(named: "bar_hopper logo")
        imageView.image = image
        navigationItem.titleView = imageView
        
        
        bars = Bars()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getLocation()
        navigationController?.setToolbarHidden(false, animated: true)
        bars.loadData {
            self.tableView.reloadData()
        }
        print("🚗")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        signIn()
    }
    
    func signIn() {
        
        let providers: [FUIAuthProvider] = [
            FUIFacebookAuth()]
        let currentUser = authUI.auth?.currentUser
        if currentUser == nil {
            //no current user signed in
            self.authUI.providers = providers
            present(authUI.authViewController(), animated: true, completion: nil)
        } else {
            tableView.isHidden = false
//            barUser = barUser(user: currentUser!)
//            barUser.saveIfNewUser()
        }
    }
    
    @objc func loadList(){
        //load data here
        print(bars.barArray[0].name)
        DispatchQueue.main.async {
            self.tableView.reloadData()
            print("🏆 Loaded")
        }
//        bars.loadData {
//
//        }
//        dispatch_async(dispatch_get_main_queue(),
//                       { self.tableView.reloadData() })
        
    }
    
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(alertAction)
        present(alertController, animated: true, completion: nil)
    }
    
//    func dismissViewController() {
//        if let presenter = presentingViewController as? FilterViewController {
//       
//            self.tableView.reloadData()
//        }
//        dismiss(animated: true, completion: nil)
//    }
    
    
    func buttonTapped(cell: BarTableViewCell) {
        guard let indexPath = self.tableView.indexPath(for: cell) else {
            // Note, this shouldn't happen - how did the user tap on a button that wasn't on screen?
            return
        }
        newIndexPath = indexPath.row
        performSegue(withIdentifier: "UpdateSegue", sender: nil)
       
        
        //  Do whatever you need to do with the indexPath
        
        print("Button tapped on row \(indexPath.row)")
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowSegue" {
            let destination = segue.destination as! BarDetailViewController
            let selectedIndexPath = tableView.indexPathForSelectedRow!
            destination.bar = bars.barArray[selectedIndexPath.row]
        } else if segue.identifier == "UpdateSegue" {
            let destination = segue.destination as! UpdateViewController
            let selectedIndexPath = newIndexPath
            destination.bar = bars.barArray[selectedIndexPath]
            print(selectedIndexPath)
        } else if segue.identifier == "FilterSegue" {
            let destination = segue.destination as! FilterViewController
            destination.bars = bars
            destination.bars.barArray = destination.bars.barArray
            
        }
 
        else {
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                tableView.deselectRow(at: selectedIndexPath, animated: true)
            }
        }
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        present(autocompleteController, animated: true, completion: nil)
        
        
    }
    
    
    @IBAction func signOutPressed(_ sender: UIBarButtonItem) {
        do {
            try authUI!.signOut()
            print("^^^ Successfully signed out")
            tableView.isHidden = true
            signIn()
        } catch {
            tableView.isHidden = true
            print("*** ERROR: Couldn't sign out")
            
        }
    }
}
    
//    func sortBasedOnSegmentPressed() {
//        switch sortSegmentedControl.selectedSegmentIndex {
//        case 0: //A-Z
//            bars.barArray.sort(by: {$0.name < $1.name})
//        case 1: //Closest
//            bars.barArray.sort(by: {$0.location.distance(from: currentLocation) < $1.location.distance(from: currentLocation)} )
//        case 2: //Avg. Rating
//            print("TODO")
//        default:
//            print("*** ERROR: Hey, you shouldn't have gotten here. Our segmented control only has 3 segments")
//
//
//        }
//        tableView.reloadData()
//    }
    
//    @IBAction func sortSegmentPressed(_ sender: UISegmentedControl) {
//        sortBasedOnSegmentPressed()
//    }
//
//}

extension BarListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bars.barArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! BarTableViewCell
        cell.delegate = self
        cell.configureCell(bar: bars.barArray[indexPath.row])
        return cell

    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    
}

extension BarListViewController: FUIAuthDelegate {
    func application(_app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any]) -> Bool {
        let sourceApplication = options[UIApplication.OpenURLOptionsKey.sourceApplication] as! String?
        if FUIAuth.defaultAuthUI()?.handleOpen(url, sourceApplication: sourceApplication) ?? false {
            return true
        }
        //other URL handling goes here.
//
//        let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
       
        return false
    }
    
    
    
    func authUI(_ authUI: FUIAuth, didSignInWith user: User?, error: Error?) {
        //handle user and error as necessary
        if let user = user {
            let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
            Auth.auth().signInAndRetrieveData(with: credential) { (authResult, error) in
                if let error = error {
                    print("No 🎲 \(error)")
                    return
                }
                
                // User is signed in
                // ...
            

            self.tableView.isHidden = false
            print("*** We signed in with the user \(user.email ?? "unknown email")")
            }
        }
    }
    
    func authPickerViewController(forAuthUI authUI: FUIAuth) -> FUIAuthPickerViewController {
        let loginViewController = FUIAuthPickerViewController(authUI: authUI)
        loginViewController.view.backgroundColor = UIColor.white
        
        let marginInsets: CGFloat = 16
        let imageHeight: CGFloat = 225
        let imageY = self.view.center.y - imageHeight
        let logoFrame = CGRect(x: self.view.frame.origin.x + marginInsets, y: imageY, width: self.view.frame.width - (marginInsets*2), height: imageHeight)
        let logoImageView = UIImageView(frame: logoFrame)
        logoImageView.image = UIImage(named: "bar_hopper logo")
        logoImageView.contentMode = .scaleAspectFit
        loginViewController.view.addSubview(logoImageView)
        
        return loginViewController
        
    }
    
}

extension BarListViewController: CLLocationManagerDelegate {
    
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

extension BarListViewController: GMSAutocompleteViewControllerDelegate {
    
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        bar.name = place.name
        bar.address = place.formattedAddress ?? ""
        bar.coordinate = place.coordinate
        bar.saveData { (success) in
            print(success)
        }
        dismiss(animated: true, completion: nil)
        tableView.reloadData()
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
}
