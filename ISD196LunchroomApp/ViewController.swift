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
    @IBOutlet weak var mainMenuButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        // Disable sign out buttons and only allow the user to sign in.
        mainMenuButton.isEnabled = false
        signOutButton.isEnabled = false
        signInButton.isEnabled = true
        
        // Creates listener that calls a method to change the name label when the user logs in.
        NotificationCenter.default.addObserver(self, selector: #selector(userLoggedIn),
            name: Notification.Name("userLoggedIn"), object: nil)
    
        // Setup of the default google user settings and auto-signin
        GIDSignIn.sharedInstance().scopes = [kGTLRAuthScopeSheetsSpreadsheetsReadonly]
        GIDSignIn.sharedInstance().signInSilently()
        GIDSignIn.sharedInstance().uiDelegate = self
        
        //  Do any additional setup after loading the view, typically from a nib.
    }
    
    @IBAction func signOutButtonPressed(_ sender: UIButton) {
        nameLabel.text = "Signing out..."
        
        GIDSignIn.sharedInstance().disconnect()
        GIDSignIn.sharedInstance().signOut()
        
        nameLabel.text = "Not signed in"
        
        mainMenuButton.isEnabled = false
        signOutButton.isEnabled = false
        signInButton.isEnabled = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        //  Dispose of any resources that can be recreated.
    }
    
    // Checks the email of the currently signed in user and then goes to either the student or admin main menu
    // We probably want this to be integerated into the database so we don't have to hardcode admin users
    @IBAction func mainMenuPressed(_ sender: UIButton) {
        if (GIDSignIn.sharedInstance().currentUser.profile.email.contains("@apps.district196.org")) {
            performSegue(withIdentifier: "studentMainMenu", sender: self)
        } else if (GIDSignIn.sharedInstance().currentUser.profile.email == "isd196lunchroomapp@gmail.com") {
            performSegue(withIdentifier: "adminMainMenu", sender: self)
        }
    }
    
    // The function called by the listener created up top
    @objc func userLoggedIn() {
        nameLabel.text = "Signed in as: " + GIDSignIn.sharedInstance().currentUser.profile.name
        
        mainMenuButton.isEnabled = true
        signOutButton.isEnabled = true
        signInButton.isEnabled = false
        
        if let _ = GIDSignIn.sharedInstance().currentUser {
            
            let email = GIDSignIn.sharedInstance().currentUser.profile.email!
            
            if email.contains("@apps.district196.org") {
                
                performSegue(withIdentifier: "studentMainMenu", sender: self)
                
            } else if email == "isd196lunchroomapp@gmail.com" {
                
                performSegue(withIdentifier: "adminMainMenu", sender: self)
            }
        }
    }
}

