//
//  Review.swift
//  Bar Hopper
//
//  Created by Step Cannuscio on 12/10/18.
//  Copyright © 2018 Step Cannuscio. All rights reserved.
//

import Foundation
import Firebase

class Review {
    var title: String
    var text: String
    var rating: Int
    var reviewerUserID: String
    var date: Date
    var documentID: String
    
    var dictionary: [String: Any] {
        return ["title": title, "text": text, "rating": rating, "reviewerUserID": reviewerUserID, "date": date]
    }
    
    init(title: String, text: String, rating: Int, reviewerUserID: String, date: Date, documentID: String) {
        self.title = title
        self.text = text
        self.rating = rating
        self.reviewerUserID = reviewerUserID
        self.date = date
        self.documentID = documentID
    }
    
    convenience init(dictionary: [String: Any]) {
        let title = dictionary["title"] as! String? ?? ""
        let text = dictionary["text"] as! String? ?? ""
        let rating = dictionary["rating"] as! Int? ?? 0
        let reviewerUserID = dictionary["reviewerUserID"] as! String? ?? ""
        let date = dictionary["date"] as! Date? ?? Date()
        self.init(title: title, text: text, rating: rating, reviewerUserID: reviewerUserID, date: date, documentID: "")
        
    }
    convenience init() {
        let currentUserID = Auth.auth().currentUser?.email ?? "Unknown user"
        self.init(title: "", text: "", rating: 0, reviewerUserID: currentUserID, date: Date(), documentID: "")
    }
    
    
    func saveData(bar: Bar, completed: @escaping (Bool) -> ()) {
        let db = Firestore.firestore()
        
        //Create the dictionary representing the data we want to save
        let dataToSave = self.dictionary
        //if we HAVE saved a record, we'll have a documentID
        if self.documentID != "" {
            let ref = db.collection("bars").document(bar.documentID).collection("reviews").document(self.documentID)
            ref.setData(dataToSave) { (error) in
                if let error = error {
                    print("***ERROR updating document \(self.documentID) \(error.localizedDescription)")
                    completed(false)
                } else {
                    completed(true)
                }
            }
        } else {
            var ref: DocumentReference? = nil //Let Firestore create the new documentID
            ref = db.collection("bars").document(bar.documentID).collection("reviews").addDocument(data: dataToSave) { error in
                if let error = error {
                    print("***ERROR creating new document \(self.documentID) in bar \(bar.documentID) \(error.localizedDescription)")
                    completed(false)
                } else {
                    bar.updateAverageRating {
                        completed(true)
                    }
                }
            }
        }
    }
    
    func deleteData(bar: Bar, completed: @escaping (Bool) -> ()){
        let db = Firestore.firestore()
        db.collection("bars").document(bar.documentID).collection("reviews").document(documentID).delete() { error in
            if let error = error {
                print("😡 Error deleting documentID \(self.documentID) \(error.localizedDescription)")
                completed(false)
            } else {
                bar.updateAverageRating {
                    completed(true)
                }
            }
        }
    }
}
