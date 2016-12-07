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
    //NOTE All properties that are not to be saved to firebase must be prefaced with a _ character
    var address: String = ""
    var capacity: Int = 0
    
    var city: String = ""
    var state: String = ""
    var zip: String = ""
    var phone: String = ""
    
    var _GigRef = FIRDatabase.database().reference().child("gigs")
    
    override init () {
        
        super.init()
        //Override the database reference to refer to the artist tree
        self._Ref = FIRDatabase.database().reference().child("venues")
    }
    
    override func CreateInDatabase() {
        //Call the super class method to create the venue in the database
        super.CreateInDatabase()
        
        
        //Create a reference to the UID as being an venue under the user tree
        let NewUserRef = super._UserRef.child(uid)
        //Place attributes in dict to be passed to Firebase
        let UserDict: [String: Any] =  ["type": "venue"]
        //Set the Values in DB
        NewUserRef.setValue(UserDict)
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
                if let val = (snapshot.value as AnyObject).value(forKey: "city"){
                    self.city = (val as! String)}
                if let val = (snapshot.value as AnyObject).value(forKey: "state"){
                    self.state = (val as! String)}
                if let val = (snapshot.value as AnyObject).value(forKey: "zip"){
                    self.zip = (val as! String)}
                if let val = (snapshot.value as AnyObject).value(forKey: "phone"){
                    self.phone = (val as! String)}
            
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

    func GetGigsForVID(VID: String, WithPhoto: Bool) {
        print("Retrieving Gigs for VID " + VID)
        
        
        let queryRef = _GigRef.queryOrdered(byChild: "vid").queryEqual(toValue: VID)
        
        //GigRef.queryOrdered(byChild: "vid").queryEqual(toValue: VID)
            //.observe(.childAdded, with:
        
        
        //Query the gig tree for all gigs with a VID matching this Venue. is an active listener
        queryRef.observe(.value, with: { snapshot in
            //Clear out current gig array for venue
            self._gigs.removeAll()
                //Takes each snapshot of a gig and converts it into a dictionary, then passes to a gig object for the values to be set and adds to the array
                if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                    for snap in snapshots {
                        if let gigDict = snap.value as? Dictionary<String, AnyObject> {
                            let gig = Gig()
                            gig.setValuesForKeysWithDictionary(dict: gigDict)
                            if WithPhoto {
                                if !gig.photoURL.isEmpty{
                                    gig.RetrievePhoto(gig.photoURL)
                                }
                            }
                            self._gigs.append(gig)
                        }
                    }
                }
                
                let nc = NotificationCenter.default
                nc.post(name: Notification.Name(rawValue: "GotGigsForVenue"),
                        object: nil,
                        userInfo: ["success": true])

                //print(snapshot.children)
                
               // print(snapshot.childrenCount) // I got the expected number of items
                //let enumerator = snapshot.children
                //while let rest = enumerator.nextObject() as? FIRDataSnapshot {
                    //print(rest.value)
                    
                    //Pass gig snapshot object and have it initialize itself from it
                    
                //}
                
                
                //for key in snapshot.children {
                    //let newGig = Gig()
                    //newGig.RetrieveWithID(key as! String)
                    
                //}
                //Create gig object and call gig inititializer. 
                //Catch gig init notification and add resulting gig to venue array

            }) { (error) in
                print(error.localizedDescription)
                
                let nc = NotificationCenter.default
                nc.post(name: Notification.Name(rawValue: "GotGigsForVenue"),
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
