//
//  ViewController.swift
//  On The Map
//
//  Created by Ahmed Onawale on 10/31/15.
//  Copyright © 2015 Ahmed Onawale. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class LoginViewController: UIViewController {
    
    // MARK: Properties

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailLoginButton: UIButton!
    @IBOutlet weak var facebookLoginButton: UIButton!
    
    var apiController: APIClient!
    var keyboardAdjusted = false
    var lastKeyboardOffset : CGFloat = 0.0
    
    // MARK: Login
    
    @IBAction func loginWithEmail(sender: UIButton) {
        view.endEditing(true)
        if emailTextField.text!.isEmpty || passwordTextField.text!.isEmpty {
            shakeView(sender)
            return
        }
        let activityIndicator = addActivityIndicatortoButton(sender)
        sender.enabled = false
        facebookLoginButton.enabled = false
        apiController.loginUserWithEmail(emailTextField.text!, password: passwordTextField.text!) { success, error in
            dispatch_async(dispatch_get_main_queue()) {
                activityIndicator.removeFromSuperview()
                sender.enabled = true
                self.facebookLoginButton.enabled = true
                success ? self.completeLogin() : {
                    self.shakeView(sender)
                    self.showAlertWithTitle(error!.localizedDescription)
                }()
            }
        }
    }
    
    private func shakeView(view: UIView) {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.07
        animation.repeatCount = 4
        animation.autoreverses = true
        animation.fromValue = NSValue(CGPoint: CGPointMake(view.center.x - 10, view.center.y))
        animation.toValue = NSValue(CGPoint: CGPointMake(view.center.x + 10, view.center.y))
        view.layer.addAnimation(animation, forKey: "position")
    }
    
    private func addActivityIndicatortoButton(button: UIButton) -> UIActivityIndicatorView {
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .White)
        let origin = CGPoint(x: button.frame.size.width - 40, y: 0.0)
        let size = CGSize(width: button.frame.size.height, height: button.frame.size.height)
        activityIndicator.frame = CGRect(origin: origin, size: size)
        button.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        return activityIndicator
    }
    
    private func showAlertWithTitle(title: String) {
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func loginWithFacebook(sender: UIButton) {
        view.endEditing(true)
        let activityIndicator = addActivityIndicatortoButton(sender)
        sender.enabled = false
        emailLoginButton.enabled = false
        FBSDKLoginManager().logInWithReadPermissions(["public_profile"], fromViewController: self) { result, error in
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                dispatch_async(dispatch_get_main_queue()) {
                    activityIndicator.removeFromSuperview()
                    sender.enabled = true
                    self.emailLoginButton.enabled = true
                    self.shakeView(sender)
                    self.showAlertWithTitle(error.localizedDescription)
                }
                return
            }
            
            /* GUARD: Was permission cancelled? */
            guard !result.isCancelled else {
                dispatch_async(dispatch_get_main_queue()) {
                    activityIndicator.removeFromSuperview()
                    sender.enabled = true
                    self.emailLoginButton.enabled = true
                }
                return
            }
            
            /* GUARD: Do we have a valid result? */
            guard result != nil,
                let token = result.token.tokenString else {
                dispatch_async(dispatch_get_main_queue()) {
                    activityIndicator.removeFromSuperview()
                    sender.enabled = true
                    self.emailLoginButton.enabled = true
                    self.shakeView(sender)
                }
                return
            }
            
            self.apiController.loginWithFacebookAccessToken(token) { success, error in
                dispatch_async(dispatch_get_main_queue()) {
                    activityIndicator.removeFromSuperview()
                    sender.enabled = true
                    self.emailLoginButton.enabled = true
                    success ? self.completeLogin() : {
                        self.shakeView(sender)
                        self.showAlertWithTitle(error!.localizedDescription)
                    }()
                }
            }
        }
    }
    
    private func completeLogin() {
        guard let controller = self.storyboard?.instantiateViewControllerWithIdentifier("OnTheMapTabBarController") as? UITabBarController else {
            return
        }
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    // MARK: - View controller LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.text = "ahmedonawale@yahoo.com"
        passwordTextField.text = "pr0t0c0l"
        apiController = APIClient.sharedInstance
        
        /* Configure the UI */
        configureUI()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        unsubscribeToKeyboardNotifications()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        guard let view = touches.first?.view else {
            return
        }
        view.endEditing(true)
    }
}

extension LoginViewController {
    
    func configureUI() {
        
        /* Configure background gradient */
        self.view.backgroundColor = UIColor.clearColor()
        let colorTop = UIColor(red: 0.99, green: 0.59, blue: 0.04, alpha: 1.0).CGColor
        let colorBottom = UIColor(red: 0.99, green: 0.44, blue: 0, alpha: 1.0).CGColor
        let backgroundGradient = CAGradientLayer()
        backgroundGradient.colors = [colorTop, colorBottom]
        backgroundGradient.locations = [0.0, 1.0]
        backgroundGradient.frame = view.frame
        view.layer.insertSublayer(backgroundGradient, atIndex: 0)

        /* Configure email textfield */
        emailTextField.textColor = UIColor(red: 0.99, green: 0.44, blue: 0, alpha: 1.0)
        emailTextField.attributedPlaceholder = NSAttributedString(string: emailTextField.placeholder!, attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
        emailTextField.tintColor = UIColor(red: 0.0, green:0.502, blue:0.839, alpha: 1.0)
        
        /* Configure password textfield */
        passwordTextField.textColor = UIColor(red: 0.99, green: 0.44, blue: 0, alpha: 1.0)
        passwordTextField.attributedPlaceholder = NSAttributedString(string: passwordTextField.placeholder!, attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
        passwordTextField.tintColor = UIColor(red: 0.0, green:0.502, blue:0.839, alpha: 1.0)
        
        /* Configure login button*/
        emailLoginButton.backgroundColor = UIColor(red: 0.95, green: 0.33, blue: 0, alpha: 1.0)
        emailLoginButton.layer.cornerRadius = 3.0
        
    }
}

// MARK: - LoginViewController (Show/Hide Keyboard)

extension LoginViewController {
    
    private func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if keyboardAdjusted == false {
            lastKeyboardOffset = getKeyboardHeight(notification) / 2
            self.view.superview?.frame.origin.y -= lastKeyboardOffset
            keyboardAdjusted = true
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if keyboardAdjusted == true {
            self.view.superview?.frame.origin.y += lastKeyboardOffset
            keyboardAdjusted = false
        }
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.CGRectValue().height
    }
}

// MARK: - UITextField Extension

extension UITextField {
    @IBInspectable public var leftSpacer:CGFloat {
        get {
            if let l = leftView {
                return l.frame.size.width
            } else {
                return 0
            }
        } set {
            leftViewMode = .Always
            leftView = UIView(frame: CGRect(x: 0, y: 0, width: newValue, height: frame.size.height))
        }
    }
}

