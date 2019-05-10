//
//  ALaCarteTableViewCell.swift
//  ISD196LunchroomApp
//
//  Created by Sam on 12/17/18.
//  Copyright © 2018 district196.org. All rights reserved.
//

import UIKit

class ALaCarteTableViewCell: UITableViewCell {

    @IBOutlet weak var itemLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var addItemButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func addItemToOrder(_ sender: UIButton) {
        
        if itemsOrdered.count >= 6 {
            
            let removedName = itemsOrdered[0].name
            itemsOrdered.remove(at: 0)
            
            NotificationCenter.default.post(name: Notification.Name("itemLimitReached"), object: nil, userInfo: ["removedName": removedName])
        }
        
        let item = MenuItem(name: itemLabel.text!, price: priceLabel.text!)
        itemsOrdered.append(item)
        let price = Double(item.price.suffix(4))
        totalPrice += price!
        NotificationCenter.default.post(name: Notification.Name("itemOrdered"), object: nil)
        Order.reloadItemCount()
    }
}
