//
//  AddItemTableViewCell.swift
//  ISD196LunchroomApp
//
//  Created by Sam on 2/22/19.
//  Copyright © 2019 district196.org. All rights reserved.
//

import UIKit

class AddItemTableViewCell: UITableViewCell {
    
    //MARK: Outlets
    @IBOutlet weak var itemLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    @IBAction func addItemToMenu(_ sender: UIButton) {
        
        NotificationCenter.default.post(name: Notification.Name("addedItem"), object: nil, userInfo: ["itemName": itemLabel.text!])
    }
}
