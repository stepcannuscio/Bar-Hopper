//
//  UpdateViewController.swift
//  Bar Hopper
//
//  Created by Step Cannuscio on 12/11/18.
//  Copyright © 2018 Step Cannuscio. All rights reserved.
//

import UIKit

class UpdateViewController: UIViewController {

    @IBOutlet weak var updateView: UIView!
    @IBOutlet weak var updateButton: UIButton!
    @IBOutlet weak var waitTimeLabel: UILabel!
    @IBOutlet weak var waitTimeSlider: UISlider!
    
    
    var bar: Bar!
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        
        let blurEffect = UIBlurEffect(style: .dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        //always fill the view
        blurEffectView.frame = self.view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        view.insertSubview(blurEffectView, aboveSubview: updateView)
        view.insertSubview(blurEffectView, belowSubview: updateView)
        updateView.layer.cornerRadius = updateView.frame.size.width / 12

        
   
    }
    
    @IBAction func waitTimeSliderChanged(_ sender: UISlider) {
        let waitRounded = waitTimeSlider.value.rounded()
        waitTimeLabel.text = "\(waitRounded) min"
        
        if waitTimeSlider.value < 20 {
            waitTimeSlider.tintColor = UIColor.green
            waitTimeLabel.textColor = UIColor.green
        } else if waitTimeSlider.value >= 20 && waitTimeSlider.value <= 40 {
            waitTimeSlider.tintColor = UIColor.yellow
            waitTimeLabel.textColor = UIColor.yellow
        } else if waitTimeSlider.value > 40 {
            waitTimeSlider.tintColor = UIColor.red
            waitTimeLabel.textColor = UIColor.red
        }
        
        
    }
    
    
    @IBAction func updateButton(_ sender: UIButton) {
        let waitRounded = waitTimeSlider.value.rounded()
        bar.waitTime = Int(waitRounded)
        print(bar.waitTime)
        dismiss(animated: true, completion: nil)
        bar.saveData { _ in
            print("Saved")
        }
        }
    }
    
    

