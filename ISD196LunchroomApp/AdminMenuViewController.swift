//
//  AdminMenuViewController.swift
//  ISD196LunchroomApp
//
//  Created by Sam on 12/10/18.
//  Copyright © 2018 district196.org. All rights reserved.
//

import UIKit

class AdminMenuViewController: UIViewController {

    @IBAction func logOutPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "toLoginMenu", sender: self)
    }
    
    @IBAction func editDatabasePressed(_ sender: UIButton) {
        performSegue(withIdentifier: "editDatabase", sender: self)
    }
    
    @IBAction func viewOrderDataPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "viewOrderDataPressed", sender: self)
    }
    
    @IBAction func editLunchMenusPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "EditLunchMenuPressed", sender: self)
    }
    
    @IBAction func editALaCarteMenuPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "EditALaCarteMenuPressed", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        shouldSignOut = true //App will now sign out user after pressing the Log Out button
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}
