//
//  Double+roundTo.swift
//  Bar Hopper
//
//  Created by Step Cannuscio on 12/10/18.
//  Copyright © 2018 Step Cannuscio. All rights reserved.
//

import Foundation

//rounds any Double to "places" places, e.g. if value = 3.275, value.roundTo(places: 1) returns 3.3
extension Double {
    func roundTo(places: Int) -> Double {
        let tenToPower = pow(10.0, Double((places >= 0) ? places : 0))
        let roundedValue = (self * tenToPower).rounded() / tenToPower
        return roundedValue
    }
}
