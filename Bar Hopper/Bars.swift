//
//  Bars.swift
//  Bar Hopper
//
//  Created by Step Cannuscio on 12/10/18.
//  Copyright © 2018 Step Cannuscio. All rights reserved.
//

import Foundation
import Firebase

class Bars {
    var barArray = [Bar]()
    var db: Firestore!
    
    init() {
        db = Firestore.firestore()
    }
    
    func loadData(completed: @escaping () -> ()) {
        
        db.collection("bars").addSnapshotListener { (querySnapshot, error) in
            guard error == nil else {
                print("*** ERROR: adding the snapshot listen \(error!.localizedDescription)")
                return completed()
            }
            self.barArray = []
            //there are querySnapshot!.documents.count documents in the spots snapshot
            for document in querySnapshot!.documents {
                let bar = Bar(dictionary: document.data())
                bar.documentID = document.documentID
                self.barArray.append(bar)
            }
            completed()
            
        }
    }
}
