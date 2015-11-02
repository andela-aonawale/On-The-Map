//
//  MapViewController.swift
//  On The Map
//
//  Created by Ahmed Onawale on 10/31/15.
//  Copyright © 2015 Ahmed Onawale. All rights reserved.
//

import UIKit
import MapKit
import FBSDKCoreKit
import FBSDKLoginKit

class MapViewController: UIViewController {
    
    // MARK: Properties
    
    var apiController: APIClient!
    var dataModel: DataModel!
    @IBOutlet weak var mapView: MKMapView!
    
    @IBAction func logout(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true) {
            self.apiController.logOut()
            FBSDKLoginManager().logOut()
        }
    }
    
    @IBAction func addStudentLocation(sender: UIBarButtonItem) {
        guard let _ = dataModel.objectID else {
            performSegueWithIdentifier("Add Student Location", sender: nil)
            return
        }
        let alert = UIAlertController(title: "You have already posted a student location. Would you like to overwrite your current Location?", message: nil, preferredStyle: .Alert)
        let overwrite = UIAlertAction(title: "Overwite", style: .Default) { action in
            self.performSegueWithIdentifier("Add Student Location", sender: true)
        }
        alert.addAction(overwrite)
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        presentViewController(alert, animated: true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard segue.identifier == "Add Student Location" && (sender as? Bool) == true else {
            super.prepareForSegue(segue, sender: sender)
            return
        }
        guard let controller = segue.destinationViewController as? AddPinViewController else {
            return
        }
        controller.isUpdating = true
    }
    
    // MARK: - View controller LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        apiController = APIClient.sharedInstance
        dataModel = DataModel.sharedInstance
        
        downloadStudentsLocationsFromParse()
        let annotations = annotationsFromData(hardCodedLocationData())
        mapView.addAnnotations(annotations)
        mapView.showAnnotations(annotations, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

// MARK: - MKMapViewDelegate

extension MapViewController: MKMapViewDelegate {
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation.isKindOfClass(MKUserLocation) || !(annotation is Annotation) {
            return nil
        }
        let reuseId = "pin"
        var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId)
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            annotationView?.canShowCallout = true
            annotationView?.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        } else {
            annotationView?.annotation = annotation as! Annotation
        }
        return annotationView
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            if let subtitle = view.annotation?.subtitle! {
                UIApplication.sharedApplication().openURL(NSURL(string: subtitle)!)
            }
        }
    }
    
}

// MARK: - Load hardcoded data and parse data

extension MapViewController {
    
    private func downloadStudentsLocationsFromParse() {
        apiController.fetchRecentStudentsLocation { result, error in
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                let alert = UIAlertController(title: "Unable to download recent student locations", message: nil, preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
                return
            }
            guard let result = result else {
                return
            }
            let annotations = self.annotationsFromData(result)
            self.mapView.addAnnotations(annotations)
        }
    }
    
    private func annotationForStudent(student: StudentInformation) -> Annotation {
        let coordinate = CLLocationCoordinate2D(latitude: student.latitude, longitude: student.longitude)
        let annotation = Annotation(firstName: student.firstName, lastName: student.lastName, mediaURL: student.mediaURL, coordinate: coordinate)
        return annotation
    }
    
    private func annotationsFromData(data: [[String: AnyObject]]) -> [Annotation] {
        var annotations = [Annotation]()
        
        for student in data {
            let studentInformation = StudentInformation(student: student)
            dataModel.studentInformations.append(studentInformation)
            annotations.append(annotationForStudent(studentInformation))
        }
        return annotations
    }
    
    private func hardCodedLocationData() -> [[String : AnyObject]] {
        return  [
            [
                "createdAt" : "2015-02-24T22:27:14.456Z",
                "firstName" : "Jessica",
                "lastName" : "Uelmen",
                "latitude" : 28.1461248,
                "longitude" : -82.75676799999999,
                "mapString" : "Tarpon Springs, FL",
                "mediaURL" : "www.linkedin.com/in/jessicauelmen/en",
                "objectId" : "kj18GEaWD8",
                "uniqueKey" : 872458750,
                "updatedAt" : "2015-03-09T22:07:09.593Z"
            ], [
                "createdAt" : "2015-02-24T22:35:30.639Z",
                "firstName" : "Gabrielle",
                "lastName" : "Miller-Messner",
                "latitude" : 35.1740471,
                "longitude" : -79.3922539,
                "mapString" : "Southern Pines, NC",
                "mediaURL" : "http://www.linkedin.com/pub/gabrielle-miller-messner/11/557/60/en",
                "objectId" : "8ZEuHF5uX8",
                "uniqueKey" : 2256298598,
                "updatedAt" : "2015-03-11T03:23:49.582Z"
            ], [
                "createdAt" : "2015-02-24T22:30:54.442Z",
                "firstName" : "Jason",
                "lastName" : "Schatz",
                "latitude" : 37.7617,
                "longitude" : -122.4216,
                "mapString" : "18th and Valencia, San Francisco, CA",
                "mediaURL" : "http://en.wikipedia.org/wiki/Swift_%28programming_language%29",
                "objectId" : "hiz0vOTmrL",
                "uniqueKey" : 2362758535,
                "updatedAt" : "2015-03-10T17:20:31.828Z"
            ], [
                "createdAt" : "2015-03-11T02:48:18.321Z",
                "firstName" : "Jarrod",
                "lastName" : "Parkes",
                "latitude" : 34.73037,
                "longitude" : -86.58611000000001,
                "mapString" : "Huntsville, Alabama",
                "mediaURL" : "https://linkedin.com/in/jarrodparkes",
                "objectId" : "CDHfAy8sdp",
                "uniqueKey" : 996618664,
                "updatedAt" : "2015-03-13T03:37:58.389Z"
            ]
        ]
    }
    
}
