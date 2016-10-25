//
//  AppDelegate.swift
//  Opus
//
//  Created by Rob on 10/5/16.
//  Copyright © 2016 RobMWalsh. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var storyboard: UIStoryboard?
    override init() {
        super.init()
        //Google Firebase configuration
        FIRApp.configure()
        // not really needed unless you really need it FIRDatabase.database().persistenceEnabled = true
    }
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        //Google Firebase configuration
        //FIRApp.configure()
        //Create reference to database
        var ref: FIRDatabaseReference!
        ref = FIRDatabase.database().reference()
        
        //Check if user is authenticated, if so skip log in screen
        self.storyboard =  UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let currentUser = FIRAuth.auth()?.currentUser
        if currentUser != nil
        {
            print("User is auth'd, sending to Dashboard")
            self.window?.rootViewController = self.storyboard?.instantiateViewControllerWithIdentifier("DashboardViewController")
        }
        else
        {
            print("No log in found, sending to log in screen")
            self.window?.rootViewController = self.storyboard?.instantiateViewControllerWithIdentifier("MainViewController")
        }
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

