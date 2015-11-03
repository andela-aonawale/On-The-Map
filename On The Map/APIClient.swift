//
//  API.swift
//  On The Map
//
//  Created by Ahmed Onawale on 10/31/15.
//  Copyright © 2015 Ahmed Onawale. All rights reserved.
//

import Foundation

class APIClient {
    
    // MARK: Properties
    
    private let baseURLSecureString = "https://www.udacity.com"
    private let parseBaseURLSecureString = "https://api.parse.com"
    private var dataModel = DataModel.sharedInstance
    
    class var sharedInstance : APIClient {
        struct Static {
            static var onceToken: dispatch_once_t = 0
            static var instance: APIClient? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = APIClient()
        }
        return Static.instance!
    }
    
    private func errorWithDomain(domain: String) -> NSError {
        let error = NSError(domain: domain, code: 0100, userInfo: [NSLocalizedDescriptionKey: domain])
        return error
    }
    
    private func parseData(data: NSData) -> AnyObject? {
        let parsedResult: AnyObject?
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
        } catch {
            parsedResult = nil
            print("Could not parse the data as JSON: '\(data)'")
        }
        return parsedResult
    }
    
    func updateStudentLocationWith(latitude: Double, longitude: Double, mediaURL: String, mapString: String, completionHandler: (success: Bool, error: NSError?) -> Void) {
        /* 1. Build the URL */
        let URLComponents = NSURLComponents(string: parseBaseURLSecureString)!
        URLComponents.path = "/1/classes/StudentLocation/\(dataModel.objectID!)"
        
        let request = NSMutableURLRequest(URL: URLComponents.URL!)
        request.HTTPMethod = "PUT"
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\"uniqueKey\": \"1234\", \"firstName\": \"\(dataModel.firstName!)\", \"lastName\": \"\(dataModel.lastName!)\",\"mapString\": \"\(mapString)\", \"mediaURL\": \"\(mediaURL)\",\"latitude\": \(latitude), \"longitude\": \(longitude)}".dataUsingEncoding(NSUTF8StringEncoding)
        
        /* Make the request */
        makeRequest(request) { (data, error) -> Void in
            /* GUARD: Was there an error? */
            guard (error == nil) && (data != nil) else {
                completionHandler(success: false, error: error)
                return
            }
            
            /* Parse the data */
            guard let parsedResult = self.parseData(data!) else {
                completionHandler(success: false, error: self.errorWithDomain("Cannot parse the data."))
                return
            }
            
            /* GUARD: Is the "sessionID" key in parsedResult? */
            guard let _ = parsedResult["updatedAt"] as? String else {
                print("Cannot find key 'objectId' in \(parsedResult)")
                completionHandler(success: false, error: self.errorWithDomain("Cannot find key 'objectId' in parsed result"))
                return
            }
            
            completionHandler(success: true, error: nil)
        }
    }
    
    func loginWithFacebookAccessToken(accessToken: String, completionHandler: (success: Bool, error: NSError?) -> Void) {
        /* 1. Build the URL */
        let URLComponents = NSURLComponents(string: baseURLSecureString)!
        URLComponents.path = "/api/session"
        
        let request = NSMutableURLRequest(URL: URLComponents.URL!)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\"facebook_mobile\": {\"access_token\": \"\(accessToken)\"}}".dataUsingEncoding(NSUTF8StringEncoding)
        
        /* Make the request */
        makeRequest(request) { (data, error) -> Void in
            /* GUARD: Was there an error? */
            guard (error == nil) && (data != nil) else {
                completionHandler(success: false, error: error)
                return
            }
            
            /* subset response data! */
            let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5))
            
            /* Parse the data */
            guard let parsedResult = self.parseData(newData) else {
                print("Cannot parse data from Udacity.")
                completionHandler(success: false, error: self.errorWithDomain("Cannot parse data from Udacity."))
                return
            }
            
            /* GUARD: Did Udacity return an error? */
            guard (parsedResult.objectForKey("status_code") == nil) else {
                print("Udacity returned an error. See the status_code and status_message in \(parsedResult)")
                completionHandler(success: false, error: self.errorWithDomain("Udacity returned an error."))
                return
            }
            
            /* GUARD: Is the "sessionID" key in parsedResult? */
            guard let session = parsedResult["session"] as? [String: AnyObject],
                sessionID = session["id"] as? String,
                account = parsedResult["account"] as? [String: AnyObject],
                accountKey = account["key"] as? String else {
                    print("Cannot find key 'sessionID' in \(parsedResult)")
                    completionHandler(success: false, error: self.errorWithDomain("Cannot authenticate user."))
                    return
            }
            
            self.dataModel.sessionID = sessionID
            self.getUserPublicDataFromWithAccountKey(accountKey, completionHandler: completionHandler)
        }
    }
    
    func postStudentLocationWith(latitude: Double, longitude: Double, mediaURL: String, mapString: String, completionHandler: (success: Bool, error: NSError?) -> Void) {
        /* 1. Build the URL */
        let URLComponents = NSURLComponents(string: parseBaseURLSecureString)!
        URLComponents.path = "/1/classes/StudentLocation"

        let request = NSMutableURLRequest(URL: URLComponents.URL!)
        request.HTTPMethod = "POST"
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.HTTPBody = "{\"uniqueKey\": \"1234\", \"firstName\": \"\(dataModel.firstName!)\", \"lastName\": \"\(dataModel.lastName!)\",\"mapString\": \"\(mapString)\", \"mediaURL\": \"\(mediaURL)\",\"latitude\": \(latitude), \"longitude\": \(longitude)}".dataUsingEncoding(NSUTF8StringEncoding)
        
        /* Make the request */
        makeRequest(request) { (data, error) -> Void in
            /* GUARD: Was there an error? */
            guard (error == nil) && (data != nil) else {
                completionHandler(success: false, error: error)
                return
            }
            
            /* Parse the data */
            guard let parsedResult = self.parseData(data!) else {
                completionHandler(success: false, error: self.errorWithDomain("Cannot parse the data."))
                return
            }

            /* GUARD: Is the "sessionID" key in parsedResult? */
            guard let objectID = parsedResult["objectId"] as? String else {
                print("Cannot find key 'objectId' in \(parsedResult)")
                completionHandler(success: false, error: self.errorWithDomain("Cannot find key 'objectId' in parsed result"))
                return
            }
            
            self.dataModel.objectID = objectID
            completionHandler(success: true, error: nil)
        }
    }
    
    func logOut() {
        /* 1. Build the URL */
        let URLComponents = NSURLComponents(string: baseURLSecureString)!
        URLComponents.path = "/api/session"
        
        let request = NSMutableURLRequest(URL: URLComponents.URL!)
        request.HTTPMethod = "DELETE"
        var xsrfCookie: NSHTTPCookie? = nil
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        
        dataModel.sessionID = nil
        dataModel.firstName = nil
        dataModel.lastName = nil
        
        /* Make the request */
        makeRequest(request) { (data, error) -> Void in
            /* GUARD: Was there an error? */
            guard (error == nil) && (data != nil) else {
                return
            }
            
            /* subset response data! */
            let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5))
            
            /* 5. Parse the data */
            guard let parsedResult = self.parseData(newData) else {
                return
            }
            
            /* GUARD: Did Udacity return an error? */
            guard (parsedResult.objectForKey("status_code") == nil) else {
                print("Udacity returned an error. See the status_code and status_message in \(parsedResult)")
                return
            }
            
            /* GUARD: Is the "sessionID" key in parsedResult? */
            guard let session = parsedResult["session"] as? [String: AnyObject],
                _ = session["id"] as? String else {
                    print("Cannot find key 'sessionID' in \(parsedResult)")
                    return
            }
        }
    }
    
    private func makeRequest(request: NSMutableURLRequest, completionHandler: (data: NSData?, error: NSError?) -> Void) {
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                print("There was an error with your request: \(error)")
                completionHandler(data: nil, error: error)
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                if let response = response as? NSHTTPURLResponse {
                    print("Your request returned an invalid response! Status code: \(response.statusCode)!")
                } else if let response = response {
                    print("Your request returned an invalid response! Response: \(response)!")
                } else {
                    print("Your request returned an invalid response!")
                }
                completionHandler(data: nil, error: self.errorWithDomain("Your request returned an invalid response!"))
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                print("No data was returned by the request!")
                completionHandler(data: nil, error: self.errorWithDomain("Your email or password was incorrect."))
                return
            }
            
            completionHandler(data: data, error: nil)
        }
        
        task.resume()
    }
    
    func fetchRecentStudentsLocation(completionHandler: (result: [[String: AnyObject]]?, error: NSError?) -> Void) {
        /* Build the URL */
        let URLComponents = NSURLComponents(string: parseBaseURLSecureString)
        URLComponents?.path = "/1/classes/StudentLocation"
        URLComponents?.query = "limit=100&order=-updatedAt"

        let request = NSMutableURLRequest(URL: URLComponents!.URL!)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        /* Make the request */
        makeRequest(request) { (data, error) -> Void in
            /* GUARD: Was there an error? */
            guard (error == nil) && (data != nil) else {
                completionHandler(result: nil, error: error)
                return
            }
            
            /* Parse the data */
            guard let parsedResult = self.parseData(data!) else {
                return
            }

            /* GUARD: Is the "sessionID" key in parsedResult? */
            guard let result = parsedResult["results"] as? [[String: AnyObject]] else {
                print("Cannot find key 'results' in \(parsedResult)")
                return
            }
            
            /* Pass the result to the caller of this method */
            completionHandler(result: result, error: nil)
        }
    }
    
    func loginUserWithEmail(email: String, password: String, completionHandler: (success: Bool, error: NSError?) -> Void) {
        /* 1. Build the URL */
        let URLComponents = NSURLComponents(string: baseURLSecureString)
        URLComponents?.path = "/api/session"
        
        /* 2. Set the parameters */
        let requestBody = "{\"udacity\": {\"username\": \"\(email)\", \"password\": \"\(password)\"}}"
        
        /* 3. Configure the request */
        let request = NSMutableURLRequest(URL: URLComponents!.URL!)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = requestBody.dataUsingEncoding(NSUTF8StringEncoding)
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                print("There was an error with your request: \(error)")
                completionHandler(success: false, error: error!)
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                if let response = response as? NSHTTPURLResponse {
                    print("Your request returned an invalid response! Status code: \(response.statusCode)!")
                } else if let response = response {
                    print("Your request returned an invalid response! Response: \(response)!")
                } else {
                    print("Your request returned an invalid response!")
                }
                completionHandler(success: false, error: self.errorWithDomain("Your email or password was incorrect."))
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                print("No data was returned by the request!")
                completionHandler(success: false, error: self.errorWithDomain("Your email or password was incorrect."))
                return
            }
            
            /* subset response data! */
            let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
            
            /* 5. Parse the data */
            guard let parsedResult = self.parseData(newData) else {
                print("Cannot parse data from Udacity.")
                completionHandler(success: false, error: self.errorWithDomain("Cannot verify longin details from Udacity."))
                return
            }
            
            /* GUARD: Did Udacity return an error? */
            guard (parsedResult.objectForKey("status_code") == nil) else {
                print("Udacity returned an error. See the status_code and status_message in \(parsedResult)")
                completionHandler(success: false, error: self.errorWithDomain("Udacity returned an error."))
                return
            }
            
            /* GUARD: Is the "sessionID" key in parsedResult? */
            guard let session = parsedResult["session"] as? [String: AnyObject],
                sessionID = session["id"] as? String,
                account = parsedResult["account"] as? [String: AnyObject],
                accountKey = account["key"] as? String else {
                    print("Cannot find key 'sessionID' in \(parsedResult)")
                    completionHandler(success: false, error: self.errorWithDomain("Cannot authenticate with Udacity."))
                    return
            }
            
            self.dataModel.sessionID = sessionID
            self.getUserPublicDataFromWithAccountKey(accountKey, completionHandler: completionHandler)
        }
        
        task.resume()
    }
    
    func getUserPublicDataFromWithAccountKey(accountKey: String, completionHandler: (success: Bool, error: NSError?) -> Void) {
        /* 1. Build the URL */
        let URLComponents = NSURLComponents(string: baseURLSecureString)!
        URLComponents.path = "/api/users/\(accountKey)"
        
        let request = NSMutableURLRequest(URL: URLComponents.URL!)
        
        makeRequest(request) { (data, error) -> Void in
            /* GUARD: Was there an error? */
            guard (error == nil) && (data != nil) else {
                completionHandler(success: false, error: error)
                return
            }
            
            /* subset response data! */
            let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5))
            
            /* Parse the data */
            guard let parsedResult = self.parseData(newData) else {
                return
            }

            /* GUARD: Did Udacity return an error? */
            guard (parsedResult.objectForKey("status_code") == nil) else {
                print("Udacity returned an error. See the status_code and status_message in \(parsedResult)")
                completionHandler(success: false, error: self.errorWithDomain("Udacity returned an error."))
                return
            }
            
            /* GUARD: Is the "sessionID" key in parsedResult? */
            guard let user = parsedResult["user"] as? [String: AnyObject],
                firstName = user["first_name"] as? String,
                lastName = user["last_name"] as? String else {
                    print("Cannot find key 'user, first and last name' in \(parsedResult)")
                    completionHandler(success: false, error: self.errorWithDomain("Cannot authenticate user."))
                    return
            }
            
            self.dataModel.firstName = firstName
            self.dataModel.lastName = lastName
            
            completionHandler(success: true, error: nil)
        }
    }
    
}