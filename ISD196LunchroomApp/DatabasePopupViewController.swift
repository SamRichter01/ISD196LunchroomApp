//
//  DatabasePopupViewController.swift
//  ISD196LunchroomApp
//
//  Created by Sam on 5/6/19.
//  Copyright © 2019 district196.org. All rights reserved.
//

import UIKit

class DatabasePopupViewController: UIViewController {
    
    @IBOutlet weak var sendingOrderLabel: UILabel!
    @IBOutlet weak var itemView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sendingOrderLabel.text = "Downloading menu from spreadsheet..."
        
        NotificationCenter.default.addObserver(self, selector: #selector(menuUpdated),
            name: Notification.Name("menuUpdated"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(itemsLoaded),
            name: Notification.Name("itemsLoaded"), object: nil)
        
        itemView.layer.cornerRadius = 15
        itemView.layer.masksToBounds = false
        itemView.layer.shadowRadius = 10
        itemView.layer.shadowOpacity = 0.1
        // Do any additional setup after loading the view.
    }
    
    @objc func itemsLoaded () {
        sendingOrderLabel.text = "Uploading menu to database..."
    }
    
    @objc func menuUpdated () {
        self.dismiss(animated: true, completion: nil)
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
