//
//  ALaCarteMenuTableViewCell.swift
//  ISD196LunchroomApp
//
//  Created by SCHOEPKE, SAMUEL on 1/16/19.
//  Copyright © 2019 district196.org. All rights reserved.
//

import UIKit

class ALaCarteMenuTableViewCell: UITableViewCell {
    
    //MARK: Outlets
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
