//
//  EditMenuCollectionReusableView.swift
//  ISD196LunchroomApp
//
//  Created by Sam on 2/25/19.
//  Copyright © 2019 district196.org. All rights reserved.
//

import UIKit

class EditMenuCollectionReusableView: UICollectionReusableView {
    
    @IBOutlet weak var lineLabel: UILabel!
    
    @IBAction func removeLinePressed(_ sender: UIButton) {
        
        NotificationCenter.default.post(name: NSNotification.Name("removeLinePressed"), object: nil, userInfo: ["lineName": lineLabel.text!])
    }
}
