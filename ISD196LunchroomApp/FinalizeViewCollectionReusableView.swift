//
//  FinalizeViewCollectionReusableView.swift
//  ISD196LunchroomApp
//
//  Created by Sam on 1/31/19.
//  Copyright © 2019 district196.org. All rights reserved.
//

import UIKit

class FinalizeViewCollectionReusableView: UICollectionReusableView {
        
    @IBOutlet weak var lineLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var removeLineButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundView.isHidden = true
    }
    
    @IBAction func removeLinePressed(_ sender: UIButton) {
        
        if lineLabel.text == mealName {
            
            mealOrdered = [String]()
            mealName = ""
            mealPrice = ""
            
        } else {
            
            for x in 0..<itemsOrdered.count {
                
                if lineLabel.text == itemsOrdered[x].name {
                    
                    itemsOrdered.remove(at: x)
                    break
                }
            }
        }
        
        if let price = Double(priceLabel.text!.suffix(4)) {
            totalPrice -= price
        }
        
        NotificationCenter.default.post(name: Notification.Name("itemRemoved"), object: nil)
        Order.reloadItemCount()
    }
    
}
