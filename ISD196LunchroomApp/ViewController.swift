//
//  SignInViewController.swift
//  ISD196LunchroomApp
//
//  Created by Sam on 12/7/18.
//  Copyright © 2018 district196.org. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore
import GoogleAPIClientForREST
import GoogleSignIn

class ViewController: UIViewController, GIDSignInUIDelegate {

    @IBOutlet weak var signInButton: GIDSignInButton!
    @IBOutlet weak var signOutButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        signOutButton.isEnabled = false
        signInButton.isEnabled = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(userLoggedIn),
                       name: Notification.Name("UserLoggedIn"),
                       object: nil)
        
        GIDSignIn.sharedInstance().signInSilently()
        GIDSignIn.sharedInstance().uiDelegate = self
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @IBAction func signOutButtonPressed(_ sender: UIButton) {
        
        nameLabel.text = "Signing out..."
        
        GIDSignIn.sharedInstance().disconnect()
        GIDSignIn.sharedInstance().signOut()
        
        nameLabel.text = "Not signed in"
        
        signOutButton.isEnabled = false
        signInButton.isEnabled = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func userLoggedIn() {
        
        nameLabel.text = "Signed in as: " + GIDSignIn.sharedInstance().currentUser.profile.name
        
        signOutButton.isEnabled = true
        signInButton.isEnabled = false
    }
    
    func sign(_ signIn: GIDSignIn!, present viewController: UIViewController!) {
        
    }
    
    func sign(_ signIn: GIDSignIn!, dismiss viewController: UIViewController!) {
        
    }
}

