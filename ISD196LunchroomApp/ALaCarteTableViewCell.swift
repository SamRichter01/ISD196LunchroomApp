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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
