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

class GigMapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    let regionRadius: CLLocationDistance = 6000
    
    var selectedAnnotation: GigAnnotation!
    
    var GigRef = FIRDatabase.database().reference().child("gigs")
    
    var VenueRef = FIRDatabase.database().reference().child("venues")
    
    var gigLocations: [CLLocationCoordinate2D] = []
    
    var Venues: [String:Venue]? = nil
    
    var InitialLocSet = false
    
    //var initialLocation = CLLocation(latitude: lat, longitude: lon)
    
    var lat: Double = 0.0
    var lon: Double = 0.0
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //When false Updating locations will center the map to the current lat lon
        InitialLocSet = false
        mapView.delegate = self
        mapView.showsUserLocation = true
        
        //Navigation controller
        navigationController?.navigationBar.barTintColor = UIColor.black
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        let backItem = UIBarButtonItem()
        backItem.title = ""
        backItem.tintColor = UIColor.white
        navigationItem.backBarButtonItem = backItem
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.isNavigationBarHidden = true
        
        GetGigs()
        
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = true
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.startUpdatingLocation()
        
        
    }
    
  

   

    func GetGigs() {
        var loc = CLLocationCoordinate2D()
        
        //Need to call gig,set value for snapshot method
        //Then add to dictionary that maps annotations to the gig object that needs to be passed
                GigRef.observe(.value, with: { groupKeys in
                    for groupKey in groupKeys.children {
                       
                        self.GigRef.child((groupKey as AnyObject).key).observeSingleEvent(of: .value, with: { snapshot in
                            
                            let dropPin = GigAnnotation()
                            
                            if let val = (snapshot.value as AnyObject).value(forKey: "lat"){
                                loc.latitude = (val as! Double)
                            }
                            if let val = (snapshot.value as AnyObject).value(forKey: "lon"){
                                loc.longitude = (val as! Double)
                            }
                            if let val = (snapshot.value as AnyObject).value(forKey: "name"){
                                dropPin.title = (val as! String)
                            }
                            if let val = (snapshot.value as AnyObject).value(forKey: "vid"){
                                dropPin.vid = (val as! String)
                            }
                            
                            //print("The vid is " + dropPin.vid)
                            
                            dropPin.coordinate = loc
                            
                            self.mapView.addAnnotation(dropPin)
                            self.gigLocations.append(loc)
                        })
                    }
                })
        
                //Need to check each prop to see if the key exists before extracting and setting
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        print("Annotation selected")
        //Called when an annotation is selected on the map
        if let annotation = view.annotation as? GigAnnotation {
            print("Your annotation title: " + annotation.title!)
            selectedAnnotation = annotation
            print("the slected annotation vid is: ", selectedAnnotation.vid)
        }
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        //Called when the info button is tapped on the annotation
        if control == view.rightCalloutAccessoryView {
            //selectedAnnotation = view.annotation as! GigAnnotation!
            print("Annotation button tapped")
            
            
            let DestinationVC = self.storyboard!.instantiateViewController(withIdentifier: "VenueDashboard") as! VenueDashboardViewController
            DestinationVC.VIDForLoad = selectedAnnotation.vid
            //let navController = UINavigationController(rootViewController: self)
            
            //self.present(self.navigationController, animated:true, completion: nil)
            
            self.navigationController?.pushViewController(DestinationVC, animated: true)
            navigationController?.isNavigationBarHidden = false
           // performSegue(withIdentifier: "MapToVenue", sender: UIViewController.self)
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("Prepare for segue called")
        if(segue.identifier == "MapToVenue") {
            
            //let tabVc = segue.destination as! UITabBarController
            //let navVc = tabVc.viewControllers!.first as! UINavigationController
           // let VenueVc = navVc.viewControllers.first as! VenueDashboardViewController
            
           // let DestinationVC = (segue.destination as! VenueDashboardViewController)
           // let navVc = DestinationVC.first as! UINavigationController
            
           
            
            
            
            //let tabCtrl = segue.destination as! UITabBarController
            //let destinationVC = tabCtrl.viewControllers![0] as! VenueDashboardViewController
            //let DestinationVC = (segue.destination.navigationController?.topViewController as! VenueDashboardViewController)
            //DestinationVC.VIDForLoad = selectedAnnotation.vid
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        //Adds info button to annotation
        
        let annotationIdentifier = "ID"
        
        var view = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier)
        if view == nil {
            view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            view?.canShowCallout = true
            view?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        } else {
            view?.annotation = annotation
        }
        return view
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
    /* func GetVenues() {
     var loc = CLLocationCoordinate2D()
     
     //Need to call gig,set value for snapshot method
     //Then add to dictionary that maps annotations to the gig object that needs to be passed
     VenueRef.observe(.value, with: { groupKeys in
     for groupKey in groupKeys.children {
     
     self.VenueRef.child((groupKey as AnyObject).key).observeSingleEvent(of: .value, with: { snapshot in
     
     let dropPin = MKPointAnnotation()
     
     // let btn = UIButton(type: .detailDisclosure)
     // dropPin.rightCalloutAccessoryView = btn
     
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
     self.venues[
     
     //Create setValues from dict for user class and artist and venue subclasses
     //Initialize venue using new method
     //add venues to dictionary here with VID as key
     //pass venue to venue dashboard
     
     })
     }
     })
     
     //Need to check each prop to see if the key exists before extracting and setting
     } */
}
