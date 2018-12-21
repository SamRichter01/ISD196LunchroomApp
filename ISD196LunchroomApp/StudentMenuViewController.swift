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
        if (monthlyMenus.count != 0) {
            performSegue(withIdentifier: "quickOrder", sender: self)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
 
        //Creates a dispatch group to be used to stop code. enter() function starts the pause of the code.
        let group = DispatchGroup()
        group.enter()
        
        //This function allows the code inside to be run while all other code is paused. leave() function resumes all code.
        DispatchQueue.main.async {
            MasterMenu.downloadALaCarteItems()
            MasterMenu.downloadMenuItems()
            MasterMenu.downloadMonthlyMenus()
            group.leave()
        }
        
        // Do any additional setup after loading the view.
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
