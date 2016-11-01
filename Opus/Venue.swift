//
//  Venue.swift
//  Opus
//
//  Created by Rob on 10/31/16.
//  Copyright © 2016 RobMWalsh. All rights reserved.
//

import Foundation

import CoreLocation
import UIKit
import Firebase

class Venue : User {
    
    var address: String = ""
    var capacity: Int = 0
    
    override init () {
        
        super.init()
        //Override the database reference to refer to the artist tree
        self._Ref = FIRDatabase.database().reference().child("venues")
    }
    
    func RetrieveVenueForUser(_ UID: String){
        //Retrieve user from DB with given UID
        self._Ref.child(UID).observeSingleEvent(of: .value, with: { (snapshot) in
            //print("Retrieved the below Venue and attributes:")
            //print(snapshot.value)
            //Need to check each prop to see if the key exists before extracting and setting
            //If we found something
            if snapshot.value is NSNull {
                print("No Venue found")
            }else{
                print("Retrieved venue data for user ", "\(UID)")
                self.uid = UID
                if let val = (snapshot.value as AnyObject).value(forKey: "address"){
                    self.address = val as! String}
                if let val = (snapshot.value as AnyObject).value(forKey: "capacity"){
                    self.capacity = (val as! Int)}
            
                //Post notification that the user was initalized from the database succesfully, include the user info success message
                let nc = NotificationCenter.default
                nc.post(name: Notification.Name(rawValue: "VenueInit"),
                    object: nil,
                    userInfo: ["success": true])
            
                //Call to the super class to retrieve the rest of the common properties
                super.RetrieveWithID(UID)
                
            }
        }) { (error) in
            print(error.localizedDescription)
            //Post notification that the user was initalized from the database succesfully, don't include the success message
            let nc = NotificationCenter.default
            nc.post(name: Notification.Name(rawValue: "VenueInit"),
                                    object: nil,
                                    userInfo: nil)
        }
        
    }

    override func toDict() -> [String:AnyObject] {
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
        //Add properties of User superclass
        let SuperSelf = otherSelf.superclassMirror
        for child in SuperSelf!.children {
            let firstChar = child.label![(child.label?.startIndex)!]
            if firstChar != "_"{
                if let key = child.label {
                    dict[key] = child.value as? AnyObject
                }
            }
        }
        
        //print(dict)
        return dict
    }

    
    
}
