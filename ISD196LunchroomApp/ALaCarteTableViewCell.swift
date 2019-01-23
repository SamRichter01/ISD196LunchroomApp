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
        self.isSelected = true
        let item = MenuItem(index: "0", name: itemLabel.text!, price: priceLabel.text!)
        itemsOrdered.append(item)
        let price = Double(item.price.suffix(4))
        totalPrice += price!
        NotificationCenter.default.post(name: Notification.Name("itemRemoved"), object: nil)
        Order.reloadItemCount()
    }
}
