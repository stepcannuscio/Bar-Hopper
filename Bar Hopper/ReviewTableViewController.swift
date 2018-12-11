//
//  ReviewTableViewController.swift
//  Bar Hopper
//
//  Created by Step Cannuscio on 12/10/18.
//  Copyright © 2018 Step Cannuscio. All rights reserved.
//

import UIKit
import Firebase

class ReviewTableViewController: UITableViewController {
    
    @IBOutlet var starButtonCollection: [UIButton]!
    @IBOutlet weak var buttonsBackgroundView: UIView!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var saveBarButton: UIBarButtonItem!
    @IBOutlet weak var cancelBarButton: UIBarButtonItem!
    @IBOutlet weak var reviewTextView: UITextView!
    @IBOutlet weak var reviewDateLabel: UILabel!
    @IBOutlet weak var reviewTitleField: UITextField!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var waitTimeSlider: UISlider!
    @IBOutlet weak var waitTimeLabel: UITextField!
    
    
    var bar: Bar!
    var review: Review!
    let dateFormatter = DateFormatter()
    var rating = 0 {
        didSet {
            for starButton in starButtonCollection {
                let image = UIImage(named: (starButton.tag < rating ? "star-filled": "star empty"))
                starButton.setImage(image, for: .normal)
            }
            review.rating = rating
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //hide keyboard if we tap outside of a field
//        let tap = UITapGestureRecognizer(target: self.view, action:  #selector(UIView.endEditing(_:)))
//        tap.cancelsTouchesInView = false
//        self.view.addGestureRecognizer(tap)
        
        guard bar != nil else {
            print("**** ERROR: Did not have a valid spot in ReviewDetailViewController")
            return
        }
        if review == nil {
            review = Review()
        }
        updateUserInterface()
    }
    
    func updateUserInterface() {
        nameLabel.text = bar.name
        addressLabel.text = bar.address
        rating = review.rating
        reviewTitleField.text = review.title
        enableDisableSaveButton()
        reviewTextView.text = review.text
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        reviewDateLabel.text = "posted: \(dateFormatter.string(from: review.date))"
        if review.documentID == "" { //This is a new review
//            addBordersToEditableObjects()
        } else {
            if review.reviewerUserID == Auth.auth().currentUser?.email { //This review was posted by current user
                self.navigationItem.leftItemsSupplementBackButton = false
                saveBarButton.title = "Update"
//                addBordersToEditableObjects()
                deleteButton.isHidden = false
            } else { //This review was posted by a different user
                cancelBarButton.title = ""
                saveBarButton.title = ""
//                postedByLabel.text = "Posted by: \(review.reviewerUserID)"
                //disable stars
                for starImage in starButtonCollection {
                    starImage.backgroundColor = UIColor.white
                    starImage.adjustsImageWhenDisabled = false
                    starImage.isEnabled = false
                    reviewTitleField.isEnabled = false
                    reviewTextView.isEditable = false
                    reviewTitleField.backgroundColor = UIColor.white
                    reviewTextView.backgroundColor = UIColor.white
                }
            }
        }
    }
//
//    func addBordersToEditableObjects() {
//        reviewTitleField.addBorder(width: 0.5, radius: 5.0, color: .black)
//        reviewTextView.addBorder(width: 0.5, radius: 5.0, color: .black)
//        buttonsBackgroundView.addBorder(width: 0.5, radius: 5.0, color: .black)
//    }
    
    func enableDisableSaveButton() {
        if reviewTitleField.text != "" {
            saveBarButton.isEnabled = true
        } else {
            saveBarButton.isEnabled = false
        }
    }
    
    func leaveViewController() {
        let isPresentingInAddMode = presentingViewController is UINavigationController
        if isPresentingInAddMode {
            dismiss(animated: true, completion: nil)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    func saveThenSegue() {
        review.title = reviewTitleField.text!
        review.text = reviewTextView.text!
        review.saveData(bar: bar) { (success) in
            if success {
                self.leaveViewController()
            } else {
                print("Couldn't leave this view controller b/c wasn't saved")
            }
        }
        leaveViewController()
    }
    
    @IBAction func waitTimeSliderChanged(_ sender: UISlider) {
        let waitTime = waitTimeSlider.value.rounded()
    
        waitTimeLabel.text = "\(waitTime) min"
        
    
    }
    
    @IBAction func starButtonPressed(_ sender: UIButton) {
          rating = sender.tag + 1 //add one since we're 0 indexed
    }

    @IBAction func reviewTitleChanged(_ sender: UITextField) {
         enableDisableSaveButton()
    }
    
    
    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
         saveThenSegue()
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        leaveViewController()
    }
    
    @IBAction func deleteButtonPressed(_ sender: UIButton) {
        review.deleteData(bar: bar) { success in
            if success {
                self.leaveViewController()
            } else {
                print("😡 Error: delete unsuccessfully")
            }
        }
        leaveViewController()
    }
    }
    

