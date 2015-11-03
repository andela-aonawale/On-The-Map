//
//  ListTableViewController.swift
//  On The Map
//
//  Created by Ahmed Onawale on 10/31/15.
//  Copyright © 2015 Ahmed Onawale. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class ListTableViewController: UITableViewController {
    
    // MARK: Properties
    
    var dataModel: DataModel!
    var apiClient: APIClient!
    
    @IBAction func logout(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true) {
            self.apiClient.logOut()
            FBSDKLoginManager().logOut()
        }
    }
    
    @IBAction func refreshStudentLocations(sender: UIBarButtonItem) {
        sender.enabled = false
        apiClient.fetchRecentStudentsLocation { result, error in
            dispatch_async(dispatch_get_main_queue()) {
                sender.enabled = true
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
                self.dataModel.studentInformations.removeAll()
                for student in result {
                    let studentInformation = StudentInformation(student: student)
                    self.dataModel.studentInformations.append(studentInformation)
                }
                self.tableView.reloadData()
            }
        }
    }
    
    @IBAction func addStudentLocation(sender: UIBarButtonItem) {
        guard let _ = dataModel.objectID else {
            performSegueWithIdentifier("Add Student Location", sender: nil)
            return
        }
        let alert = UIAlertController(title: "You have already posted a student location. Would you like to overwrite your current Location?", message: nil, preferredStyle: .Alert)
        let overwrite = UIAlertAction(title: "Overwite", style: .Default) { action in
            self.performSegueWithIdentifier("Add Student Location", sender: sender)
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        alert.addAction(overwrite)
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
        
        apiClient = APIClient.sharedInstance
        dataModel = DataModel.sharedInstance
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataModel.studentInformations.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Student Cell", forIndexPath: indexPath)
        
        let student = dataModel.studentInformations[indexPath.row]
        cell.textLabel?.text = "\(student.firstName) \(student.lastName)"
        cell.detailTextLabel?.text = student.mediaURL
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let student = dataModel.studentInformations[indexPath.row]
        if let mediaURL = NSURL(string: student.mediaURL) {
            UIApplication.sharedApplication().openURL(mediaURL)
        }
    }

}
