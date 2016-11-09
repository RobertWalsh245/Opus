//
//  Gig.swift
//  Opus
//
//  Created by Rob on 11/3/16.
//  Copyright © 2016 RobMWalsh. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit
import Firebase

class Gig {
    //NOTE: Any property declared with a leading "_" character will be excluded from the JSON dicionary creation function
    
    //A reference to the users node in the database
    //let _UserRef = FIRDatabase.database().reference().child("users")
    //A reference to the root of User
    var _Ref = FIRDatabase.database().reference()
    //A reference to the storage buckets within firebase
    fileprivate var _StorageRef = FIRStorage.storage().reference(forURL: "gs://opus-f0c01.appspot.com")
    fileprivate var _GigRef = FIRDatabase.database().reference().child("gigs")

    var gid: String = ""
    var name: String = ""
    var date: NSDate = NSDate()
    var description: String = ""
    var photoURL: String = ""
    var vid: String = ""
    var sets: Int = 1
    var setduration: NSDate = NSDate()
    var address: String = ""
    var city: String = ""
    var state: String = ""
    var zip: String = ""
    var phone: String = ""
    var time: NSDate = NSDate()
    
    
    //var rate: Double = 0.0
    
    func CreateInDatabase(){
        //Generate a unique id for the gig and set it as the GID
        let NewGigRef = _GigRef.childByAutoId()
        self.gid = NewGigRef.key
        
        //Check for values in 3 mandatory properties before continuing
        if(!self.gid.isEmpty || self.name.isEmpty || self.vid.isEmpty){
            //Place attributes in dict to be passed to Firebase
            //let UserDict = [Any?]()
            let GigDict: [String: Any] =  ["name": self.name,
                                           "vid": self.vid]
            //Set the Values in DB
            NewGigRef.setValue(GigDict)
            print("Added gig ", "\(gid)", " to database")
        }else{
            print("No name and/or GID. Gig not added to database")
        }
    }
    
    func UpdateInDatabase() {
        //Check for values in 3 mandatory properties before continuing
        if(!self.gid.isEmpty || self.name.isEmpty || self.vid.isEmpty){
            
            //Reference to the GID of this gig object
            let NewGigRef = self._GigRef.child(gid)
            //Place attributes in dict to be passed to Firebase
            let GigDict = self.toDict()
            //Set the Values in DB
            NewGigRef.updateChildValues(GigDict)
            print("Updated details for Gig ", "\(gid)", " in database")
        }else{
            print("No email and/or UID. Gig not updated in database")
        }
        
    }
    
    func toDict() -> [String:AnyObject] {
        //Converts all properties to dictionary, excludes any with a leading "_" character
        //print("Converting to dict")
        var dict = [String:AnyObject]()
        let otherSelf = Mirror(reflecting: self)
        for child in otherSelf.children {
            let firstChar = child.label![(child.label?.startIndex)!]
            if firstChar != "_"{
                if let key = child.label {
                    dict[key] = child.value as? AnyObject
                }
            }
        }
        //  print(dict)
        return dict
    }
    
    
    
    
}
