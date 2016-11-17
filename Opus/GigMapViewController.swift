//
//  GigMapViewController.swift
//  Opus
//
//  Created by Rob on 11/15/16.
//  Copyright © 2016 RobMWalsh. All rights reserved.
//

import UIKit
import MapKit
import Firebase

class GigMapViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    let regionRadius: CLLocationDistance = 6000
    
    var GigRef = FIRDatabase.database().reference().child("gigs")
    
    var gigLocations: [CLLocationCoordinate2D] = []
    
    var InitialLocSet = false
    
    //var initialLocation = CLLocation(latitude: lat, longitude: lon)
    
    var lat: Double = 0.0
    var lon: Double = 0.0
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //When false Updating locations will center the map to the current lat lon
        InitialLocSet = false
        
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        
        GetGigs()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.startUpdatingLocation()
        
        
    }

    func GetGigs() {
        var loc = CLLocationCoordinate2D()
        
        
                GigRef.observe(.value, with: { groupKeys in
                    for groupKey in groupKeys.children {
                       
                        self.GigRef.child((groupKey as AnyObject).key).observeSingleEvent(of: .value, with: { snapshot in
                            
                            let dropPin = MKPointAnnotation()
                            
                            if let val = (snapshot.value as AnyObject).value(forKey: "lat"){
                                loc.latitude = (val as! Double)
                            }
                            if let val = (snapshot.value as AnyObject).value(forKey: "lon"){
                                loc.longitude = (val as! Double)
                            }
                            if let val = (snapshot.value as AnyObject).value(forKey: "name"){
                                dropPin.title = (val as! String)
                            }
                            
                            
                            dropPin.coordinate = loc
                            
                            self.mapView.addAnnotation(dropPin)
                            self.gigLocations.append(loc)
                            
                            
                        })
                    }
                   
                })
                
        
                //Need to check each prop to see if the key exists before extracting and setting
    
    }
    
    func PlotGigs(){
       print("Plotting Gigs")
        for loc in gigLocations {
            
            let dropPin = MKPointAnnotation()
            dropPin.coordinate = loc
            dropPin.title = "Gig Name"
            mapView.addAnnotation(dropPin)
            
        }
        
        
        
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                                  regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        self.lat = locValue.latitude
        self.lon = locValue.longitude
        
        if(InitialLocSet == false) {
           let initialLocation = CLLocation(latitude: lat, longitude: lon)
            centerMapOnLocation(location: initialLocation)
            InitialLocSet = true
        }
        
        
        
        
        //print("Updated user location = \(locValue.latitude) \(locValue.longitude)")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
