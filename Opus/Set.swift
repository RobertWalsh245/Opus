//
//  Set.swift
//  Opus
//
//  Created by Rob on 11/21/16.
//  Copyright © 2016 RobMWalsh. All rights reserved.
//

import Foundation
import Firebase

class Set {
    
    fileprivate var _StorageRef = FIRStorage.storage().reference(forURL: "gs://opus-f0c01.appspot.com")
    fileprivate var _SetRef = FIRDatabase.database().reference().child("sets")
    
    var sid: String = ""
    var duration: String = ""
    var genre: String = ""
    var time: String = ""
    var rate: Double = 0.0
    var gid: String = ""
    var aid: String = ""
    var _DisplayRate: String {
        get {
            let currencyFormatter = NumberFormatter()
            currencyFormatter.usesGroupingSeparator = true
            currencyFormatter.numberStyle = NumberFormatter.Style.currency
            // localize to your grouping and decimal separator
            currencyFormatter.locale = NSLocale.current
            let rateString = currencyFormatter.string(from: NSNumber(value: self.rate))
            return rateString!
        }
    }

    func RetrieveWithID (_ sid: String) {
        
        //Retrieve user from DB with given UID
        _SetRef.child(sid).observeSingleEvent(of: .value, with: { (snapshot) in
            //print("Retrieved the below user and attributes:")
            //print(snapshot.value)
            //Need to check each prop to see if the key exists before extracting and setting
            
            self.sid = sid
            if let val = (snapshot.value as AnyObject).value(forKey: "gid"){
                self.gid = (val as! String)}
            if let val = (snapshot.value as AnyObject).value(forKey: "aid"){
                self.aid = (val as! String)}
            if let val = (snapshot.value as AnyObject).value(forKey: "duration"){
                self.duration = (val as! String)}
            if let val = (snapshot.value as AnyObject).value(forKey: "genre"){
                self.genre = (val as! String)}
            if let val = (snapshot.value as AnyObject).value(forKey: "rate"){
                self.rate = (val as! Double)}
            if let val = (snapshot.value as AnyObject).value(forKey: "time"){
                self.time = (val as! String)}
            
            
            //Post notification that the user was initalized from the database succesfully, include the user info success message
            let nc = NotificationCenter.default
            nc.post(name: Notification.Name(rawValue: "SetInit"),
                    object: self,
                    userInfo: ["success": true])
        }) { (error) in
            print(error.localizedDescription)
            //Post notification that the user was initalized from the database succesfully, don't include the success message
            let nc = NotificationCenter.default
            nc.post(name: Notification.Name(rawValue: "SetInit"),
                    object: nil,
                    userInfo: nil)
        }
        
    }
    
    
    func setValuesForKeysWithDictionary(dict: Dictionary<String, AnyObject>) {
        //Initializes the gig based on a passed in dictionary
        //print("Setting gig values from dictionary")
        if let val = dict["sid"] {
            self.sid = val as! String}
        if let val = dict["gid"] {
            self.gid = val as! String}
        if let val = dict["aid"] {
            self.aid = val as! String}
        if let val = dict["duration"]{
            self.duration = (val as! String)}
        if let val = dict["genre"]{
            self.genre = (val as! String)}
        if let val = dict["time"]{
            self.time = (val as! String)}
        if let val = dict["rate"]{
            self.rate = (val as! Double)}
    }

    
    func CreateInDatabase(){
        //Generate a unique id for the gig and set it as the GID
        let NewSetRef = _SetRef.childByAutoId()
        self.sid = NewSetRef.key
        
        //Check for values in 3 mandatory properties before continuing
        if(!self.sid.isEmpty && self.rate >= 0 && !self.gid.isEmpty && !self.time.isEmpty && !self.genre.isEmpty){
            //Place attributes in dict to be passed to Firebase
            //let UserDict = [Any?]()
            let SetDict: [String: Any] =  ["sid": self.sid,
                                           "gid": self.gid,
                                           "time": self.time,
                                           "rate": self.rate,
                                           "genre": self.genre]
            //Set the Values in DB
            NewSetRef.setValue(SetDict)
            print("Added set ", "\(sid)", " to database")
        }else{
            print("No name and/or SID. Set not added to database")
        }
    }
    
    func UpdateInDatabase() {
        //Check for values in 3 mandatory properties before continuing
        if(!self.sid.isEmpty && self.rate >= 0 && !self.gid.isEmpty && !self.time.isEmpty && !self.genre.isEmpty){
            
            //Reference to the GID of this gig object
            let NewSetRef = self._SetRef.child(sid)
            //Place attributes in dict to be passed to Firebase
            let SetDict = self.toDict()
            //Set the Values in DB
            NewSetRef.updateChildValues(SetDict)
            print("Updated details for Set ", "\(sid)", " in database")
        }else{
            print("No sid / gid, incorrect rate / time. Set not updated in database")
        }
        
    }
    
    
    func isComplete() -> String {
        var message = "Complete"
        //Check for values in mandatory properties before continuing
        
        if self.duration.isEmpty{
            message = "Please provide a duration for the set"
        }else if self.rate <= 0.0 {
            message = "Please provide a positive rate for the set"
        }else if self.time.isEmpty {
            message = "Please set a time for the set"
       // }else if(self.gid.isEmpty) {
           // message = "Something went wrong. Please try again"
        }
        return message
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
