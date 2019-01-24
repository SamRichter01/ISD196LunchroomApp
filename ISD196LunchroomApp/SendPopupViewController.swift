//
//  SendPopupViewController.swift
//  ISD196LunchroomApp
//
//  Created by Sam on 1/24/19.
//  Copyright © 2019 district196.org. All rights reserved.
//

import UIKit

class SendPopupViewController: UIViewController {

    @IBOutlet weak var sendingOrderLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(orderSent),
            name: Notification.Name("orderSent"), object: nil)

        // Do any additional setup after loading the view.
    }
    
    @objc func orderSent () {
        
        performSegue(withIdentifier: "returnAfterOrder", sender: self)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
