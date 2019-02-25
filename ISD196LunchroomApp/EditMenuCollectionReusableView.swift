//
//  EditMenuCollectionReusableView.swift
//  ISD196LunchroomApp
//
//  Created by Sam on 2/25/19.
//  Copyright © 2019 district196.org. All rights reserved.
//

import UIKit

class EditMenuCollectionReusableView: UICollectionReusableView {
    
    @IBOutlet weak var addItemButton: UIButton!
    @IBOutlet weak var lineLabel: UILabel!
    
    @IBAction func addItemPressed(_ sender: UIButton) {
        NotificationCenter.default.post(name: NSNotification.Name("addItemPressed"), object: nil, userInfo: ["lineName": lineLabel.text!])
    }
}
