//
//  NewItemCollectionViewCell.swift
//  ISD196LunchroomApp
//
//  Created by Sam on 3/14/19.
//  Copyright © 2019 district196.org. All rights reserved.
//

import UIKit

class NewItemCollectionViewCell: UICollectionViewCell {
    
    var lineName = ""
    
    @IBAction func addItemPressed(_ sender: UIButton) {
        NotificationCenter.default.post(name: NSNotification.Name("addItemPressed"), object: nil, userInfo: ["lineName": lineName])
    }
}
