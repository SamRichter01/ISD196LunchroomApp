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
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
