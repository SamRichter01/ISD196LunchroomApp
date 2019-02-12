//
//  StudentMenuViewController.swift
//  ISD196LunchroomApp
//
//  Created by Sam on 12/10/18.
//  Copyright © 2018 district196.org. All rights reserved.
//

import UIKit

class StudentMenuViewController: UIViewController {
    
    @IBAction func logOutPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "toLoginMenu", sender: self)
    }

    @IBAction func quickOrderPressed(_ sender: UIButton) {
            performSegue(withIdentifier: "quickOrder", sender: self)
    }
    
    @IBAction func aLaCarteMenuPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "toALaCarteMenu", sender: self)
    }
    
    @IBAction func lunchMenuPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "toLunchMenu", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        shouldSignOut = true //App will now sign out user after pressing the Log Out button
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
