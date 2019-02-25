//
//  ItemPopupViewController.swift
//  ISD196LunchroomApp
//
//  Created by Sam on 1/25/19.
//  Copyright © 2019 district196.org. All rights reserved.
//

import UIKit

class ItemPopupViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var itemView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel.text = selectedName
        priceLabel.text = selectedPrice
        
        itemView.layer.cornerRadius = 15
        itemView.layer.masksToBounds = false
        itemView.layer.shadowRadius = 10
        itemView.layer.shadowOpacity = 0.1
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
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
