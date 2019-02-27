//
//  MenuCollectionViewReusableView.swift
//  ISD196LunchroomApp
//
//  Created by Sam on 1/27/19.
//  Copyright © 2019 district196.org. All rights reserved.
//

import UIKit

class MenuCollectionViewReusableView: UICollectionReusableView {
        
    @IBOutlet weak var lineLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    @IBAction func commentButtonPressed(_ sender: UIButton) {
        
        NotificationCenter.default.post(name: NSNotification.Name("commentPressed"), object: nil, userInfo: ["lineName": lineLabel.text!])
    }
}
