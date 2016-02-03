//
//  RootViewController.swift
//  GetOnThatBus
//
//  Created by Susan Salas on 2/2/16.
//  Copyright © 2016 Susan Salas. All rights reserved.
//

import UIKit
import MapKit

class RootViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    var stopsDictionary = NSDictionary()
    var arrayOfStops = [NSDictionary]()
    let locationManager = CLLocationManager()
    var averageLatitude = Double()
    var averageLongitude = Double()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.averageLatitude = 0.0
        self.averageLongitude = 0.0
        let url = NSURL(string: "https://s3.amazonaws.com/mmios8week/bus.json")
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithURL(url!) { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            do{
                self.stopsDictionary = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments) as! NSDictionary
                self.arrayOfStops = self.stopsDictionary.objectForKey("row") as! [NSDictionary]
               // print(self.arrayOfStops)
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.mapView.reloadInputViews()
                    self.loadStops()
                })
            }
            catch let error as NSError {
                print("json error: \(error.localizedDescription)")
            }
        }
        task.resume()
        
    }

    func loadStops(){
        
        for stop in self.arrayOfStops{
        let stopAnnotation = MKPointAnnotation()
        let longitude = Double (stop.objectForKey("longitude")! as! String)
        let latitude = Double (stop.objectForKey("latitude")! as! String)
        
        self.averageLatitude = self.averageLatitude + latitude!
        self.averageLongitude = self.averageLongitude + longitude!
            
        
        stopAnnotation.coordinate = CLLocationCoordinate2DMake(latitude!, longitude!)
        self.mapView.addAnnotation(stopAnnotation)
        stopAnnotation.title = stop.objectForKey("cta_stop_name") as? String
        stopAnnotation.subtitle = stop.objectForKey("stop_id") as? String
        print(longitude, latitude)
        }
        
        let totalStops = Double (self.arrayOfStops.count)
        
        self.averageLatitude = self.averageLatitude / totalStops
        self.averageLongitude = self.averageLongitude / totalStops - 1.0
        
        let averageAnnotation = MKPointAnnotation()
        averageAnnotation.coordinate = CLLocationCoordinate2DMake(self.averageLatitude, self.averageLongitude)
        
        mapView.setRegion(MKCoordinateRegionMake(averageAnnotation.coordinate, MKCoordinateSpanMake(0.4, 0.4)), animated: true)
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let pin = MKPinAnnotationView(annotation: annotation, reuseIdentifier: nil)
        pin.canShowCallout = true
        pin.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        return pin
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        performSegueWithIdentifier("mapViewToDetail", sender: view)

    }

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
