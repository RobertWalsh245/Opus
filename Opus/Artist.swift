//
//  Artist.swift
//  Opus
//
//  Created by Rob on 10/24/16.
//  Copyright © 2016 RobMWalsh. All rights reserved.
//

import Foundation

import CoreLocation
import UIKit
import Firebase

class Artist : User {
    
    var gender: String = ""
    var genre: String = ""
    var type: String = ""
    var dob: String = ""
    //A reference to the users node in the database
    fileprivate var _ArtistRef = FIRDatabase.database().reference().child("artists")
    //A reference to the storage buckets within firebase
    fileprivate var _StorageRef = FIRStorage.storage().reference(forURL: "gs://opus-f0c01.appspot.com")
    
    
    override init () {
        
        super.init()
        //Override the database reference to refer to the artist tree
        self._Ref = FIRDatabase.database().reference().child("artists")
    }
    
    
    override func CreateInDatabase() {
        //Call the super class method to create the artist in the database
        super.CreateInDatabase()
        
        //Create a reference to the UID as being an artist under the user tree
        let NewUserRef = super._UserRef.child(uid)
        //Place attributes in dict to be passed to Firebase
        let UserDict: [String: Any] =  ["type": "artist"]
        //Set the Values in DB
        NewUserRef.setValue(UserDict)
        
    }
    
    func RetrieveArtistForUser(_ UID: String){
        //Retrieve user from DB with given UID
        self._Ref.child(UID).observeSingleEvent(of: .value, with: { (snapshot) in
            //print("Retrieved the below Artist and attributes:")
           // print(snapshot.value)
            //Need to check each prop to see if the key exists before extracting and setting
            if snapshot.value is NSNull {
                print("No Artist found")
            }else{
                print("Retrieved artist data for user ", "\(UID)")
                self.uid = UID
            
                if let val = (snapshot.value as AnyObject).value(forKey: "gender"){
                    self.gender = val as! String}
                if let val = (snapshot.value as AnyObject).value(forKey: "genre"){
                    self.genre = (val as! String)}
                if let val = (snapshot.value as AnyObject).value(forKey: "type"){
                    self.type = (val as! String)}
                if let val = (snapshot.value as AnyObject).value(forKey: "dob"){
                    self.dob = (val as! String)}
            
                //Post notification that the user was initalized from the database succesfully, include the user info success message
                let nc = NotificationCenter.default
                nc.post(name: Notification.Name(rawValue: "ArtistInit"),
                    object: nil,
                    userInfo: ["success": true])
            
                //Call to the super class to retrieve the rest of the common properties
                super.RetrieveWithID(UID)
                
            }
        }) { (error) in
            print(error.localizedDescription)
            //Post notification that the user was initalized from the database succesfully, don't include the success message
            let nc = NotificationCenter.default
            nc.post(name: Notification.Name(rawValue: "ArtistInit"),
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
