//
//  OrderCollectionViewReusableView.swift
//  ISD196LunchroomApp
//
//  Created by Sam on 1/31/19.
//  Copyright © 2019 district196.org. All rights reserved.
//

import UIKit

class OrderCollectionViewReusableView: UICollectionReusableView {
    
    @IBOutlet weak var lineLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var addToOrderButton: UIButton!
    
    var line = Line(name: "", price: "")
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    @IBAction func addToOrderPressed(_ sender: UIButton) {
        
        if priceLabel.text != "Prices vary" {
            
            let price = Double(line.price.suffix(4))
            totalPrice += price!
            
        }
        
        let meal = Line(name: lineLabel.text!, price: priceLabel.text!)
        meal.items = line.items
        mealsOrdered.append(meal)
        
        Order.reloadItemCount()
    }
    
}
