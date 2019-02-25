//
//  EditMenuCollectionViewCell.swift
//  ISD196LunchroomApp
//
//  Created by Sam on 2/25/19.
//  Copyright © 2019 district196.org. All rights reserved.
//

import UIKit

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
