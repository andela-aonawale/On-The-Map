//
//  Pin.swift
//  On The Map
//
//  Created by Ahmed Onawale on 10/31/15.
//  Copyright © 2015 Ahmed Onawale. All rights reserved.
//

import Foundation
import MapKit

final class Annotation: NSObject, MKAnnotation {
    
    // MARK: Properties
    
    var title: String?
    var subtitle: String?
    var coordinate: CLLocationCoordinate2D
    
    var latitude: Double {
        return coordinate.latitude
    }
    
    var longitude: Double {
        return coordinate.longitude
    }
    
    // MARK: Initializers
    
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
    
    init(firstName: String, lastName: String, mediaURL: String, coordinate: CLLocationCoordinate2D) {
        self.title = "\(firstName) \(lastName)"
        self.subtitle = mediaURL
        self.coordinate = coordinate
    }
    
}