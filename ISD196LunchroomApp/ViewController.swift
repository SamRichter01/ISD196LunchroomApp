//
//  SignInViewController.swift
//  ISD196LunchroomApp
//
//  Created by Sam on 12/7/18.
//  Copyright © 2018 district196.org. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import GoogleAPIClientForREST
import GoogleSignIn
import Reachability

var shouldSignOut = false //variable which allows user to be automatically signed out when returning to this view controller

class ViewController: UIViewController, GIDSignInUIDelegate, GIDSignInDelegate {

    @IBOutlet weak var signInButton: GIDSignInButton!
    @IBOutlet weak var signOutButton: UIButton!
    @IBOutlet weak var mainMenuButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    let network = NetworkManager.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Checks to see if the person is returning from the main menu after pressing the Log Out button
        if shouldSignOut {
            signOutButtonPressed()
        }
        
        activityIndicator.hidesWhenStopped = true
    
        // Disable sign out buttons and only allow the user to sign in.
        
        signInButton.isEnabled = true
        
        // Creates listener that calls a method to change the name label when the user logs in.
        NotificationCenter.default.addObserver(self, selector: #selector(userLoggedIn), name: Notification.Name("userLoggedIn"), object: nil)
    
        // Setup of the default google user settings and auto-signin
        GIDSignIn.sharedInstance().scopes = [kGTLRAuthScopeSheetsSpreadsheetsReadonly]
        GIDSignIn.sharedInstance().signInSilently()
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
        
        //Checks to see if you were previously logged in and are currently signing in silently
        if GIDSignIn.sharedInstance().hasAuthInKeychain() {
            startLoading()
            nameLabel.text = "Signing in"
        }
        
        //Gets called if device is offline when this view controller loads
        NetworkManager.isUnreachable { _ in
            DispatchQueue.main.async {
                self.nameLabel.text = "Please connect to internet before signing in"
                self.nameLabel.textColor = UIColor.red
                self.signInButton.isEnabled = false
            }
        }
        
        //Gets called when device goes offline
        network.reachability.whenUnreachable = { _ in
            DispatchQueue.main.async {
                self.nameLabel.text = "Please connect to internet before signing in"
                self.nameLabel.textColor = UIColor.red
                self.signInButton.isEnabled = false
            }
        }
        
        //Gets called when device comes online
        network.reachability.whenReachable = { _ in
            DispatchQueue.main.async {
                self.stopLoading()
                self.signInButton.isEnabled = true
            }
            
        }
    }
    
    @IBAction func googleButtonPressed(_ sender: GIDSignInButton) {
        startLoading()
        nameLabel.text = "Signing in"
    }
    
    func signOutButtonPressed() {
        nameLabel.text = "Signing out..."
        
        GIDSignIn.sharedInstance().disconnect()
        GIDSignIn.sharedInstance().signOut()
        
        nameLabel.text = "Not signed in"
        
        signInButton.isEnabled = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        //  Dispose of any resources that can be recreated.
    }
    
    
    // The function called by the listener created up top
    @objc func userLoggedIn() {
        //nameLabel.text = "Signed in as: " + GIDSignIn.sharedInstance().currentUser.profile.name
        
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
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        // ...
        if let _ = error {
            //If user cancels sign in, show all buttons and labels, and hide activity indicator
            stopLoading()
            return
        }
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        Auth.auth().signInAndRetrieveData(with: credential, completion: { (authResult, error) -> Void in
            if let _ = error {
                // ...
                return
            } else if error == nil {
                // ensures that the user that just logged in is using an approved email account, logs out if not.
                // Again, we probably want the users saved in the database so we don't have to hardcode admins in.
                if (user.profile.email.contains("@apps.district196.org")) {
                    
                    self.nameLabel.text = "Downloading Menus"
                    
                    MasterMenu.downloadALaCarteMenu()
                    MasterMenu.downloadMonthlyMenus()
                    self.downloadMenuItems()
                    
                } else if (user.profile.email == "isd196lunchroomapp@gmail.com") {
                    
                    self.nameLabel.text = "Downloading Menus"
                        
                    MasterMenu.downloadALaCarteItems()
                    MasterMenu.downloadALaCarteMenu()
                    MasterMenu.downloadMonthlyMenus()
                    MasterMenu.downloadOrderData()
                    self.downloadMenuItems()
                        
                } else {
                    //Show all buttons and remove activity indicator, along with unauthorized email message
                    self.stopLoading()
                    self.nameLabel.textColor = UIColor.red
                    self.nameLabel.text = "Please use an ISD 196 google account"
                    
                    GIDSignIn.sharedInstance().signOut()
                    GIDSignIn.sharedInstance().disconnect()
                }
            }
            // User is signed in
            // ...
        })
    }
    
    // Signs the user out upon closing the app.
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
    func downloadMenuItems() {
        
        menuItems.removeAll()
        menuItems = Dictionary<String,MenuItem>()
        
        let db = Firestore.firestore()
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
        
        // This function gets all of the documents in the Items collection in the database, and appends each one as its own MenuItem to the menuItems array
        db.collection("menus").document("Menu Items")
            .collection("Items").getDocuments(completion: { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    //Menus have finished downloading and will now be added to the array and the user will be sent to the main menu
                    for document in querySnapshot!.documents {
                        
                        if let desc = document.get("Description") as? String {
                            
                            menuItems[document.documentID] = (MenuItem.init(
                                name: document.documentID,
                                description: desc))
                        } else {
                            
                            menuItems[document.documentID] = (MenuItem.init(
                                name: document.documentID,
                                description: ""))
                        }
                        
                    }
                    NotificationCenter.default.post(name: NSNotification.Name("userLoggedIn"), object: nil)
                }
        })
    }
    
    //Hides uneccesary buttons and labels and starts the activity indicator
    func startLoading() {
        signInButton.isHidden = true
        activityIndicator.startAnimating()
        nameLabel.text = "Signing in"
        nameLabel.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    }
    
    //Shows previously hidden button and labels and stops the activity indicator
    func stopLoading() {
        signInButton.isHidden = false
        activityIndicator.stopAnimating()
        nameLabel.text = "Not signed in"
        nameLabel.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    }
}

