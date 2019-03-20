//
//  OrderDataViewReusableView.swift
//  ISD196LunchroomApp
//
//  Created by Sam on 2/21/19.
//  Copyright © 2019 district196.org. All rights reserved.
//

import UIKit

class OrderDataViewReusableView: UICollectionReusableView {
    
    @IBOutlet weak var lineLabel: UILabel!
    @IBOutlet weak var orderCountLabel: UILabel!
    
    
    @IBAction func viewCommentsPressed(_ sender: UIButton) {
        
        NotificationCenter.default.post(name: NSNotification.Name("viewCommentsPressed"), object: nil, userInfo: ["lineName": lineLabel.text!])
    }
}
