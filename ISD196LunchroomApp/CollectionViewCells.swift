//
//  CollectionViewCells.swift
//  ISD196LunchroomApp
//
//  Created by Sam on 5/13/19.
//  Copyright © 2019 district196.org. All rights reserved.
//

import UIKit

class MenuCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var itemLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}


class NewItemCollectionViewCell: UICollectionViewCell {
    
    var lineName = ""
    
    @IBAction func addItemPressed(_ sender: UIButton) {
        NotificationCenter.default.post(name: NSNotification.Name("addItemPressed"), object: nil, userInfo: ["lineName": lineName])
    }
}


class EditMenuCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var removeItemPressed: UIButton!
    @IBOutlet weak var itemLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @IBAction func removeItemPressed(_ sender: UIButton) {
        
        NotificationCenter.default.post(name: NSNotification.Name("removeItemPressed"), object: nil, userInfo: ["itemName": itemLabel.text!])
    }
}


