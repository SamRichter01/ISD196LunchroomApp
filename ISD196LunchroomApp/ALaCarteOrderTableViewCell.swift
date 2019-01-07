//
//  ALaCarteOrderTableViewCell.swift
//  ISD196LunchroomApp
//
//  Created by Sam on 1/4/19.
//  Copyright © 2019 district196.org. All rights reserved.
//

import UIKit

class ALaCarteOrderTableViewCell: UITableViewCell {

    @IBOutlet weak var itemLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var removeButton: UIButton!
    
    var cellIndex = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func removeButtonPressed(_ sender: UIButton) {
        itemsOrdered.remove(at: cellIndex)
        NotificationCenter.default.post(name: Notification.Name("itemRemoved"), object: nil)
    }
}
