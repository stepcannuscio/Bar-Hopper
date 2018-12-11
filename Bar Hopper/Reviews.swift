//
//  Reviews.swift
//  Bar Hopper
//
//  Created by Step Cannuscio on 12/10/18.
//  Copyright © 2018 Step Cannuscio. All rights reserved.
//

import Foundation
import Firebase

class Reviews {
    var reviewArray: [Review] = []
    var db: Firestore!
    
    init() {
        db = Firestore.firestore()
    }
    
    func loadData(bar: Bar, completed: @escaping () -> ()) {
        guard bar.documentID != "" else {
            return
        }
        db.collection("bars").document(bar.documentID).collection("reviews").addSnapshotListener { (querySnapshot, error) in
            guard error == nil else {
                print("*** ERROR: adding the snapshot listen \(error!.localizedDescription)")
                return completed()
            }
            self.reviewArray = []
            //there are querySnapshot!.documents.count documents in the spots snapshot
            for document in querySnapshot!.documents {
                let review = Review(dictionary: document.data())
                review.documentID = document.documentID
                self.reviewArray.append(review)
            }
            completed()
            
        }
    }
    
}
