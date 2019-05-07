//
//  EditItemTableViewCell.swift
//  ISD196LunchroomApp
//
//  Created by Sam on 5/7/19.
//  Copyright © 2019 district196.org. All rights reserved.
//

import UIKit

class EditItemTableViewCell: UITableViewCell {
    
    @IBOutlet weak var itemLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var itemDescriptionLabel: UILabel!
    @IBOutlet weak var deleteItemButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    @IBAction func removeItemPressed(_ sender: UIButton) {
        
        NotificationCenter.default.post(name: NSNotification.Name("removeALaCartePressed"), object: nil, userInfo: ["itemName": itemLabel.text!])
    }
}
