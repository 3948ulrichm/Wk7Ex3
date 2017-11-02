//
//  FirstViewController.swift
//  Wk7Ex3
//
//  Created by Michael Ulrich on 10/18/17.
//  Copyright © 2017 Michael Ulrich. All rights reserved.
//

import UIKit
import MapKit
import Firebase

class FirstViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!

    var messageNodeRef : DatabaseReference!
    
    let regionRadius: CLLocationDistance = 1000
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mapView.delegate = self
        
        // set initial location to Marquette University
        let initialLocation = CLLocation(latitude: 43.0382216, longitude: -87.9297546)
        centerMapOnLocation(location: initialLocation)
        
        //create Firebase DB reference
        messageNodeRef = Database.database().reference().child("messages")

        // use the observe handler to poll for realtime updates
        let pinMessageId = "msg-1"
        var pinMessage: Message?
        messageNodeRef.child(pinMessageId).observe(.value, with: { (snapshot: DataSnapshot) in
            
            if let dictionary = snapshot.value as? [String: Any]
            {
            // if the pin already exists, remove it first
                if pinMessage != nil
                {
                    self.mapView.removeAnnotation(pinMessage!)
                }
            
                //map the JSON tags to the Message class' properties
                let pinLat = dictionary["latitude"] as! Double
                let pinLong = dictionary["longitude"] as! Double
                let messageDisabled = dictionary["isDisabled"] as! Bool
                
                // show messages on the map
                let message = Message(title: (dictionary["title"] as? String)!,
                                      locationName: (dictionary["locationName"] as? String)!,
                                      username: (dictionary["username"] as? String)!,
                                      coordinate: CLLocationCoordinate2D(latitude: pinLat, longitude: pinLong),
                                      isDisabled: messageDisabled)
                
                pinMessage = message
                
                //if message is not disabled, show the message as an annotation
                if !message.isDisabled
                {
                    self.mapView.addAnnotation(message)
                }
            }
        })
    }
    
    var locationManager = CLLocationManager()
    
    func checkLocationAuthorizationStatus(){
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            mapView.showsUserLocation = true
        }
        else {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkLocationAuthorizationStatus()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

