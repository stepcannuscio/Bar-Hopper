//
//  BarTableViewCell.swift
//  Bar Hopper
//
//  Created by Step Cannuscio on 12/10/18.
//  Copyright © 2018 Step Cannuscio. All rights reserved.
//

import UIKit
import CoreLocation

protocol BarTableViewCellDelegate: class {
    func buttonTapped(cell: BarTableViewCell)
}

class BarTableViewCell: UITableViewCell {
    
    
        
    
        
    
        
    
    
    @IBOutlet weak var crowdedIndicatorImage: UIImageView!
    
    @IBOutlet weak var updateButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var waitTimeLabel: UILabel!
    
    @IBOutlet weak var ratingLabel: UILabel!

    var bar: Bar!
    
    var delegate: BarTableViewCellDelegate?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.delegate = nil
    }
    
    
    func configureCell(bar: Bar) {
        nameLabel.text = bar.name
        waitTimeLabel.text = "\(bar.waitTime) min"
        if bar.waitTime < 20 {
            crowdedIndicatorImage.image = UIImage(named: "green")
        } else if bar.waitTime >= 20 && bar.waitTime <= 40 {
            crowdedIndicatorImage.image = UIImage(named: "yellow")
        } else {
            crowdedIndicatorImage.image = UIImage(named: "red")
        }
        
        //round out edges of crowded indicator and update button
        crowdedIndicatorImage.layer.cornerRadius = crowdedIndicatorImage.frame.size.width / 2
        updateButton.layer.cornerRadius = updateButton.frame.size.width / 12
        let ratingText = bar.averageRating.roundTo(places: 1)
       
        ratingLabel.text = String(ratingText)
        
        
    }
    
    @IBAction func updateButton(_ sender: UIButton) {
        self.delegate?.buttonTapped(cell: self)
    }
    
}
