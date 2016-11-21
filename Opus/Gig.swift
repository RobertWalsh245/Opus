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
    var date: String = ""
    var description: String = ""
    var photoURL: String = ""
    var vid: String = ""
    var sets: Int = 1
    var setduration: String = ""
    var address: String = ""
    var city: String = ""
    var state: String = ""
    var zip: String = ""
    var phone: String = ""
    var time: String = ""
    var lat: Double = 0.0
    var lon: Double = 0.0
    var genre: String = ""
    
    func RetrieveWithID (_ GID: String) {
        
        //Retrieve user from DB with given UID
        _GigRef.child(GID).observeSingleEvent(of: .value, with: { (snapshot) in
            //print("Retrieved the below user and attributes:")
            //print(snapshot.value)
            //Need to check each prop to see if the key exists before extracting and setting
            
            self.gid = GID
            
            if let val = (snapshot.value as AnyObject).value(forKey: "name"){
                self.name = val as! String}
            if let val = (snapshot.value as AnyObject).value(forKey: "date"){
                self.date = (val as! String)}
            if let val = (snapshot.value as AnyObject).value(forKey: "description"){
                self.description = (val as! String)}
            if let val = (snapshot.value as AnyObject).value(forKey: "photoURL"){
                self.photoURL = (val as! String)}
            if let val = (snapshot.value as AnyObject).value(forKey: "vid"){
                self.vid = (val as! String)}
            if let val = (snapshot.value as AnyObject).value(forKey: "sets"){
                self.sets = (val as! Int)}
            if let val = (snapshot.value as AnyObject).value(forKey: "setduration"){
                self.setduration = (val as! String)}
            if let val = (snapshot.value as AnyObject).value(forKey: "address"){
                self.address = (val as! String)}
            if let val = (snapshot.value as AnyObject).value(forKey: "city"){
                self.city = (val as! String)}
            if let val = (snapshot.value as AnyObject).value(forKey: "state"){
                self.state = (val as! String)}
            if let val = (snapshot.value as AnyObject).value(forKey: "zip"){
                self.zip = (val as! String)}
            if let val = (snapshot.value as AnyObject).value(forKey: "time"){
                self.time = (val as! String)}
            if let val = (snapshot.value as AnyObject).value(forKey: "lat"){
                self.lat = (val as! Double)}
            if let val = (snapshot.value as AnyObject).value(forKey: "lon"){
                self.lon = (val as! Double)}
            if let val = (snapshot.value as AnyObject).value(forKey: "genre"){
                self.genre = (val as! String)}
            
            
            
            //Post notification that the user was initalized from the database succesfully, include the user info success message
            let nc = NotificationCenter.default
            nc.post(name: Notification.Name(rawValue: "GigInit"),
                    object: self,
                    userInfo: ["success": true])
        }) { (error) in
            print(error.localizedDescription)
            //Post notification that the user was initalized from the database succesfully, don't include the success message
            let nc = NotificationCenter.default
            nc.post(name: Notification.Name(rawValue: "GigInit"),
                    object: nil,
                    userInfo: nil)
        }
        
    }
    
    func setValuesForKeysWithDictionary(dict: Dictionary<String, AnyObject>) {
        //Initializes the gig based on a passed in dictionary
        //print("Setting gig values from dictionary")
        if let val = dict["gid"] {
            self.gid = val as! String}
        if let val = dict["name"] {
            self.name = val as! String}
        if let val = dict["date"]{
            self.date = (val as! String)}
        if let val = dict["description"]{
            self.description = (val as! String)}
        if let val = dict["photoURL"]{
            self.photoURL = (val as! String)}
        if let val = dict["vid"]{
            self.vid = (val as! String)}
        if let val = dict["sets"]{
            self.sets = (val as! Int)}
        if let val = dict["setduration"]{
            self.setduration = (val as! String)}
        if let val = dict["address"]{
            self.address = (val as! String)}
        if let val = dict["city"]{
            self.city = (val as! String)}
        if let val = dict["state"]{
            self.state = (val as! String)}
        if let val = dict["zip"]{
            self.zip = (val as! String)}
        if let val = dict["time"]{
            self.time = (val as! String)}
        if let val = dict["lat"]{
            self.lat = (val as! Double)}
        if let val = dict["lon"]{
            self.lon = (val as! Double)}
        if let val = dict["genre"]{
            self.genre = (val as! String)}
        
        
    }
    //var rate: Double = 0.0
    
    func CreateInDatabase(){
        //Generate a unique id for the gig and set it as the GID
        let NewGigRef = _GigRef.childByAutoId()
        self.gid = NewGigRef.key
        
        //Check for values in 3 mandatory properties before continuing
        if(!self.gid.isEmpty && !self.name.isEmpty && !self.vid.isEmpty){
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
        if(!self.gid.isEmpty && !self.name.isEmpty && !self.vid.isEmpty){
            
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
    
   
    
    func AddressToLatLon () {
        let Fulladdress = self.address + ", " + city + ", " + state + ", " + zip
        print(Fulladdress)
        //"5th Avenue, New York"
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(Fulladdress) { (placemarks, error) in
            if error != nil {
                print("Gig address conversion to lat lon failed")
                let nc = NotificationCenter.default
                nc.post(name: Notification.Name(rawValue: "ValidAddress"),
                        object: nil,
                        userInfo: nil)
            } else if let placemarks = placemarks {
                if placemarks.count != 0 {
                    self.lat = (placemarks.first?.location?.coordinate.latitude)!
                    self.lon = (placemarks.first?.location?.coordinate.longitude)!
                    print("Gig address converted to lat lon successfully")
                    let nc = NotificationCenter.default
                    nc.post(name: Notification.Name(rawValue: "ValidAddress"),
                            object: nil,
                            userInfo: ["ValidAddress": true])
                }else {
                    print("Gig address conversion to lat lon failed")
                    let nc = NotificationCenter.default
                    nc.post(name: Notification.Name(rawValue: "ValidAddress"),
                            object: nil,
                            userInfo: nil)
                }
                
                
                
            }
                
            
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
    
    func isComplete() -> String {
        var message = "Complete"
        //Check for values in mandatory properties before continuing
        
        if self.name.isEmpty{
            message = "Please provide a name for the gig"
        }else if self.lat == 0.0 {
            message = "Address is not valid"
        }else if self.sets < 1 {
            message = "Must have atleast 1 set"
        }else if self.setduration == "" {
            message = "Please specify the set duration"
        }else if(self.vid.isEmpty) {
            message = "Something went wrong. Please try again"
        }
        return message
    }
    
    
    
}
