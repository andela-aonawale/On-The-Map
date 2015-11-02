//
//  StudentInformation.swift
//  On The Map
//
//  Created by Ahmed Onawale on 10/31/15.
//  Copyright © 2015 Ahmed Onawale. All rights reserved.
//

import Foundation

// MARK: StudentInformation

struct StudentInformation {
    
    // MARK: Properties
    
    var firstName: String
    var lastName: String
    var mapString: String
    var mediaURL: String
    var latitude: Double
    var longitude: Double
    var createdAt: NSDate
    var updatedAt: NSDate
    var objectID: String
    var uniqueKey: String
    
    // MARK: Initializers
    
    init(student: [String: AnyObject]) {
        
        func dateFromString(dateString: String) -> NSDate {
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSz"
            return dateFormatter.dateFromString(dateString)!
        }
        
        self.firstName = student["firstName"] as! String
        self.lastName = student["lastName"] as! String
        self.mapString = student["mapString"] as! String
        self.mediaURL = student["mediaURL"] as! String
        self.latitude = student["latitude"] as! Double
        self.longitude = student["longitude"] as! Double
        let createdAtString = student["createdAt"] as! String
        let updatedAtString = student["updatedAt"] as! String
        self.createdAt = dateFromString(createdAtString)
        self.updatedAt = dateFromString(updatedAtString)
        self.objectID = student["objectId"] as! String
        self.uniqueKey = String(student["uniqueKey"])
    }
    
}