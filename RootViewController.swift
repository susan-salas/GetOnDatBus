//
//  RootViewController.swift
//  GetOnThatBus
//
//  Created by Susan Salas on 2/2/16.
//  Copyright © 2016 Susan Salas. All rights reserved.
//

import UIKit
import MapKit

class RootViewController: UIViewController, MKMapViewDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var mapView: MKMapView!
    var stopsDictionary = NSDictionary()
    var arrayOfStops = [NSDictionary]()
    let locationManager = CLLocationManager()
    var averageLatitude = Double()
    var averageLongitude = Double()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        segmentedControl.layer.cornerRadius = 5;
        
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
                    self.tableView.reloadData()
                })
            }
            catch let error as NSError {
                print("json error: \(error.localizedDescription)")
            }
        }
        task.resume()
        self.tableView.reloadData()
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
            //print(longitude, latitude)
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
//        print(view)
        performSegueWithIdentifier("mapViewToDetail", sender: view)

    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell")!
        let busStops = self.arrayOfStops[indexPath.row] as NSDictionary
        cell.textLabel?.text = busStops.objectForKey("cta_stop_name") as? String
        cell.detailTextLabel?.text = busStops.objectForKey("routes") as? String
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrayOfStops.count
    }
    
    @IBAction func segmentedControlTapped(sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            mapView.hidden = false
        } else {
            mapView.hidden = true
        }
    }

    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        let destination = segue.destinationViewController as! DetailViewController
//        destination.name = (sender?.objectForKey("name"))! as! String
        
    }


}
