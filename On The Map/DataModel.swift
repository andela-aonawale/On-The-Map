//
//  DataModel.swift
//  On The Map
//
//  Created by Ahmed Onawale on 11/1/15.
//  Copyright © 2015 Ahmed Onawale. All rights reserved.
//

import Foundation

final class DataModel {
    
    // MARK: Properties
    
    var sessionID: String?
    var accountKey: String?
    var firstName: String?
    var lastName: String?
    var objectID: String? {
        get {
            return NSUserDefaults.standardUserDefaults().stringForKey("objectID")
        }
        set {
            NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: "objectID")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    var studentInformations: [StudentInformation]
    
    class var sharedInstance : DataModel {
        struct Static {
            static var onceToken: dispatch_once_t = 0
            static var instance: DataModel? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = DataModel()
        }
        return Static.instance!
    }
    
    // MARK: Initializers
    
    init() {
        studentInformations = [StudentInformation]()
    }
    
}