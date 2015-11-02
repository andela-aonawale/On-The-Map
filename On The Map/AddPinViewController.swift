//
//  AddPinViewController.swift
//  On The Map
//
//  Created by Ahmed Onawale on 11/1/15.
//  Copyright © 2015 Ahmed Onawale. All rights reserved.
//

import UIKit
import MapKit

class AddPinViewController: UIViewController {
    
    // MARK: Properties
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var linkedInURLTextField: UITextField!
    @IBOutlet weak var linkedInView: UIView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var findOnMapView: UIView!
    @IBOutlet weak var addressView: UIView!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var annotation: MKPointAnnotation!
    var apiController: APIClient!
    var isUpdating = false

    @IBAction func cancel(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func submit(sender: UIButton) {
        guard let mediaURL = linkedInURLTextField.text else {
            showAlertWithTitle("Enter your LinkedIn profile URL.", message: nil)
            return
        }
        activityIndicator.startAnimating()
        activityIndicator.color = UIColor.blueColor()
        
        let latitude = annotation.coordinate.latitude
        let longitude = annotation.coordinate.longitude
        let mapString = addressTextField.text!
        
        if isUpdating {
            apiController.updateStudentLocation(latitude, longitude: longitude, mediaURL: mediaURL, mapString: mapString) { success, error in
                self.activityIndicator.stopAnimating()
                /* GUARD: Was there an error? */
                guard (error == nil) else {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.showAlertWithTitle(error!.domain, message: nil)
                    }
                    return
                }
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        } else {
            apiController.postStudentLocationWith(latitude, longitude: longitude, mediaURL: mediaURL, mapString: mapString) { success, error in
                self.activityIndicator.stopAnimating()
                /* GUARD: Was there an error? */
                guard (error == nil) else {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.showAlertWithTitle(error!.domain, message: nil)
                    }
                    return
                }
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
    }
    
    @IBAction func findOnMap(sender: UIButton) {
        guard let address = addressTextField.text else {
            showAlertWithTitle("Enter an address", message: nil)
            return
        }
        activityIndicator.startAnimating()
        geocodeAddressString(address)
    }
    
    private func addAnnotationAtCoordinate(coordinate: CLLocationCoordinate2D) {
        annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
        mapView.showAnnotations([annotation], animated: true)
    }
    
    private func showAlertWithTitle(title: String, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
        presentViewController(alert, animated: true, completion: nil)
    }
    
    private func geocodeAddressString(address: String) {
        CLGeocoder().geocodeAddressString(address) { placemarks, error in
            self.activityIndicator.stopAnimating()
            
            /* GUARD: Was there an error? */
            guard (error == nil), let location = placemarks?.first?.location else {
                dispatch_async(dispatch_get_main_queue()) {
                    self.showAlertWithTitle("Cannot find the your address on the Map.", message: nil)
                }
                return
            }
            self.showHideViews()
            self.linkedInView.backgroundColor = UIColor(red: 0.33, green: 0.54, blue: 0.71, alpha: 1)
            self.cancelButton.tintColor = UIColor.whiteColor()
            self.addAnnotationAtCoordinate(location.coordinate)
        }
    }

    private func showHideViews() {
        stackView.hidden = !stackView.hidden
        findOnMapView.hidden = !findOnMapView.hidden
        addressView.hidden = !addressView.hidden
        mapView.hidden = !mapView.hidden
        linkedInURLTextField.hidden = !linkedInURLTextField.hidden
        submitButton.hidden = !submitButton.hidden
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        guard let view = touches.first?.view else {
            return
        }
        view.endEditing(true)
    }
    
    // MARK: - View controller LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        apiController = APIClient.sharedInstance
        activityIndicator.stopAnimating()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
