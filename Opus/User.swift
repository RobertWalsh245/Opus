//
//  User.swift
//  Opus
//
//  Created by Rob on 10/10/16.
//  Copyright © 2016 RobMWalsh. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit
import Firebase

class User {
//NOTE: Any property declared with a leading "_" character will be excluded from the JSON dicionary creation function
    
    //A reference to the users node in the database
    let _UserRef = FIRDatabase.database().reference().child("users")
    //A reference to the root of User
    private var _Ref = FIRDatabase.database().reference()
    //A reference to the storage buckets within firebase
    private var _StorageRef = FIRStorage.storage().referenceForURL("gs://opus-f0c01.appspot.com")
    
    let _PhotoLimit = 3
    
    //? denotes an optional as in not required at initalization of object, will be set to nil
    var uid: String = ""
    var accountcomplete: Bool {
        get {
            //Determine if user has completed all neccesary inputs
            var Complete = true
            let UserDict = self.toDict()
            
            //Loop dictionary of all properties and check their value
            for (key, value) in UserDict {
                if UserDict[key]?.value == "" {
                    Complete = false
                }
            }
            print("Account complete = ", "\(Complete)" )
            return Complete
        }
        set(newValue) {
            //code to execute
        }
    }
    var name: String = ""
    var email: String = ""
    var bio: String = ""
    var region: String = ""
    var lat: Double = 0.0
    var lon: Double = 0.0
    var photos: [String] = []
    var dob: String = ""
    
    //Potential Methods
    //func update GPS coordinates
    //func Save User info
    //func update user default
    //func determine if user info complete
    
    init() {
        
    }
    
    init(UID: String){
        //Retrieve user from DB with given UID
        _UserRef.child(UID).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            print("Retrieved the below user and attributes:")
            print(snapshot.value)
            //Need to check each prop to see if the key exists before extracting and setting
           
            self.uid = UID
            
            if let val = snapshot.value?.valueForKey("accountcomplete"){
                self.accountcomplete = val as! Bool}
            if let val = snapshot.value?.valueForKey("name"){
                self.name = (val as! String)}
            if let val = snapshot.value?.valueForKey("email"){
                self.email = (val as! String)}
            if let val = snapshot.value?.valueForKey("bio"){
                self.bio = (val as! String)}
            if let val = snapshot.value?.valueForKey("region"){
                self.region = (val as! String)}
            if let val = snapshot.value?.valueForKey("lat"){
                self.lat = (val as! Double)}
            if let val = snapshot.value?.valueForKey("lon"){
                self.lon = (val as! Double)}
            if let val = snapshot.value?.valueForKey("photos"){
                self.photos = (val as! Array <String>)}
            if let val = snapshot.value?.valueForKey("dob"){
                self.dob = (val as! String)}
            //Post notification that the user was initalized from the database succesfully, include the user info success message
            let nc = NSNotificationCenter.defaultCenter()
            nc.postNotificationName("UserInit",
                object: nil,
                userInfo: ["success": true])
        }) { (error) in
            print(error.localizedDescription)
            //Post notification that the user was initalized from the database succesfully, don't include the success message
            let nc = NSNotificationCenter.defaultCenter()
            nc.postNotificationName("UserInit",
                                    object: nil,
                                    userInfo: nil)
        }
        
        
    }
    
    func CreateInDatabase(){
        //Check for values in 2 mandatory properties before continuing
        if(!uid.isEmpty && !email.isEmpty){
            
            //Creates a new node under "Users" equal to the UID of this user object
            let NewUserRef = self._UserRef.child(uid)
            //Place attributes in dict to be passed to FIrebase
            let UserDict: AnyObject = ["email": email,
                             "accountcomplete": accountcomplete]
            //Set the Values in DB
            NewUserRef.setValue(UserDict)
            print("Added user ", "\(uid)", " to database")
        }else{
            print("No email and/or UID. User not added to database")
        }
    }
    
    
    
    //Property that is dictionary of user info, call method to save to database
    func UpdateInDatabase() {
        //Check for values in 2 mandatory properties before continuing
        if(!uid.isEmpty && !email.isEmpty){
            
            //Reference to the UID of this user object
            let NewUserRef = self._UserRef.child(uid)
            //Place attributes in dict to be passed to Firebase
            let UserDict = self.toDict()
            //Set the Values in DB
            NewUserRef.setValue(UserDict)
            print("Updated details for user ", "\(uid)", " in database")
        }else{
            print("No email and/or UID. User not updated in database")
        }

    }
    
    func SavePhoto(image: UIImage){
        //Check if 3 photos already exist
        let imgCount = self.photos.count
        if imgCount >= self._PhotoLimit {
            print("3 Photos already saved for user.")
        }else{
            //Make sure we have a UID
            if(!uid.isEmpty){
                var data = NSData()
                data = UIImageJPEGRepresentation(image, 0.8)!
                // set upload path
                let filePath = "\(FIRAuth.auth()!.currentUser!.uid)/\("image" + String(imgCount + 1))"
                
                print(filePath)
                let metaData = FIRStorageMetadata()
                metaData.contentType = "image/jpg"
                
                self._StorageRef.child(filePath).putData(data, metadata: metaData){(metaData,error) in
                    if let error = error {
                        print(error.localizedDescription)
                        return
                    }else{
                        print("Saved photo successfully")
                        //store downloadURL
                        let downloadURL = metaData!.downloadURL()!.absoluteString
                        //store downloadURL in Photo URL array
                        self.photos.append(downloadURL)
                        self.UpdateInDatabase()
                    }
                    
                }
                
            }
            
        }
        
        func RetrievePhoto(URL: String) {
            print("Retrieving photo from URL")
            
        }
        
        //Updated all img slots in dict with the correct URLs
        //Save all urls to database
        
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
        print(dict)
        return dict
    }
    
    
    //func toAnyObject() -> Any {
            
            
            //return [
             //   "uid":uid,
             //   "accountcomplete":accountcomplete,
              //  "lat":lat
        //]
    //}
}