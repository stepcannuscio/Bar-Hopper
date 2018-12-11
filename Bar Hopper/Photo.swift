//
//  Photo.swift
//  Bar Hopper
//
//  Created by Step Cannuscio on 12/10/18.
//  Copyright © 2018 Step Cannuscio. All rights reserved.
//

import Foundation
import Firebase

class Photo {
    var image: UIImage
    var description: String
    var postedBy: String
    var date: Date
    var documentUUID: String
    var dictionary: [String: Any] {
        return ["description": description, "postedBy": postedBy, "date": date]
    }
    
    init(image: UIImage, description: String, postedBy: String, date: Date, documentUUID: String) {
        self.image = image
        self.description = description
        self.postedBy = postedBy
        self.date = date
        self.documentUUID = documentUUID
    }
    
    convenience init() {
        let postedBy = Auth.auth().currentUser?.email ?? "Unknown user"
        self.init(image: UIImage(), description: "", postedBy: postedBy, date: Date(), documentUUID: "")
    }
    
    convenience init(dictionary: [String: Any]) {
        let description = dictionary["description"] as! String? ?? ""
        let postedBy = dictionary["postedBy"] as! String? ?? ""
        let date = dictionary["date"] as! Date? ?? Date()
        self.init(image: UIImage(), description: description, postedBy: postedBy, date: date, documentUUID: "")
        
    }
    
    func saveData(bar: Bar, completed: @escaping (Bool) -> ()) {
        let db = Firestore.firestore()
        let storage = Storage.storage()
        //convert photo.image to a data type so it can be saved by Firebase Storage
        guard let photoData = self.image.jpegData(compressionQuality: 0.5) else {
            print("***ERROR could not convert photo to data")
            return completed(false)
        }
        documentUUID = UUID().uuidString //generate a unique ID to use for the photo image's name
        //create a ref to upload storage to spot.documentID's folder (bucket) with the name we created
        let storageRef = storage.reference().child(bar.documentID).child(self.documentUUID)
        let uploadTask = storageRef.putData(photoData)
        
        uploadTask.observe(.success) { (snapshot) in
            //Create the dictionary representing the data we want to save
            let dataToSave = self.dictionary
            //This will either create a new doc at documentUUID or update the existing doc with that name
            let ref = db.collection("bars").document(bar.documentID).collection("photos").document(self.documentUUID)
            ref.setData(dataToSave) { (error) in
                if let error = error {
                    print("***ERROR updating document \(self.documentUUID) \(error.localizedDescription)")
                    completed(false)
                } else {
                    completed(true)
                }
                
            }
        }
        uploadTask.observe(.failure) { (snapshot) in
            if let error = snapshot.error {
                print("***ERROR: upload task for file \(self.documentUUID) failed in bar \(bar.documentID)")
            }
            return completed(false)
        }
        
        
        
    }
}

