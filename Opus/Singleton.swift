//
//  Singleton.swift
//  Opus
//
//  Created by Rob on 11/28/16.
//  Copyright © 2016 RobMWalsh. All rights reserved.
//

import Foundation
import Firebase

final class Singleton {
    var _UserRef = FIRDatabase.database().reference().child("users")
    var currUser = User()
    
    var UID: String = ""
    var type: String = ""
    
    static let shared = Singleton()
    
    func SetUser() {
        self.UID = (FIRAuth.auth()?.currentUser?.uid)!
            //Check user tree for type of user
            _UserRef.child(self.UID).observeSingleEvent(of: .value, with: { (snapshot) in
                //print("Retrieved the below user and attributes:")
                //print(snapshot.value)
                
                
                if snapshot.exists(){
                    if let val = (snapshot.value as AnyObject).value(forKey: "type"){
                        self.type = (val as! String)
                    }
                    print("Singleton curruser set")
                    
                }else{
                    print("Singleton: User doesn't exist in DB. Signing out")
                    try! FIRAuth.auth()!.signOut()
                }
                
                //Notify the type
                let nc = NotificationCenter.default
                nc.post(name: Notification.Name(rawValue: "SingletonUserSet"),
                        object: nil,
                        userInfo: ["success": true])
                
            }) { (error) in
                print(error.localizedDescription)
                let nc = NotificationCenter.default
                nc.post(name: Notification.Name(rawValue: "SingletonUserSet"),
                        object: nil,
                        userInfo: nil)
            }
    }
    
    
}
