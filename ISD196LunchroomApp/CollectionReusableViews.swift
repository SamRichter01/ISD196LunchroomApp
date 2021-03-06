//
//  CollectionReusableViews.swift
//  ISD196LunchroomApp
//
//  Created by Sam on 5/13/19.
//  Copyright © 2019 district196.org. All rights reserved.
//

import UIKit

class EditMenuCollectionReusableView: UICollectionReusableView {
    
    @IBOutlet weak var lineLabel: UILabel!
    
    @IBAction func removeLinePressed(_ sender: UIButton) {
        
        NotificationCenter.default.post(name: NSNotification.Name("removeLinePressed"), object: nil, userInfo: ["lineName": lineLabel.text!])
    }
}


class MenuCollectionViewReusableView: UICollectionReusableView {
    
    @IBOutlet weak var lineLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var commentButton: UIButton!
    
    @IBAction func commentButtonPressed(_ sender: UIButton) {
        
        NotificationCenter.default.post(name: NSNotification.Name("commentPressed"), object: nil, userInfo: ["lineName": lineLabel.text!])
    }
}


class OrderCollectionViewReusableView: UICollectionReusableView {
    
    @IBOutlet weak var lineLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var addToOrderButton: UIButton!
    
    var line = Line(name: "", price: "")
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    @IBAction func addToOrderPressed(_ sender: UIButton) {
        
        let meal = Line(name: lineLabel.text!, price: priceLabel.text!)
        meal.items = line.items
        mealsOrdered.append(meal)
        
        if mealsOrdered.count > 3 {
            
            let removedName = mealsOrdered[0].name
            
            if let price = Double(mealsOrdered[0].price.dropFirst()) {
                
                totalPrice -= price
            }
            
            mealsOrdered.remove(at: 0)
            
            NotificationCenter.default.post(name: Notification.Name("mealLimitReached"), object: nil, userInfo: ["removedName": removedName])
        }
        
        itemCount = (itemsOrdered.count + mealsOrdered.count)
        
        if let price = Double(line.price.suffix(4)) {
            
            totalPrice += price
        }
        
        NotificationCenter.default.post(name: NSNotification.Name("lineOrdered"), object: nil, userInfo: ["line": meal])
    }
}


class FinalizeViewCollectionReusableView: UICollectionReusableView {
    
    @IBOutlet weak var lineLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var removeLineButton: UIButton!
    @IBOutlet weak var backgroundView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @IBAction func removeLinePressed(_ sender: UIButton) {
        
        for x in 0..<mealsOrdered.count {
            
            if lineLabel.text == mealsOrdered[x].name {
                
                mealsOrdered.remove(at: x)
                break
            }
        }
        
        for x in 0..<itemsOrdered.count {
            
            if lineLabel.text == itemsOrdered[x].name {
                
                itemsOrdered.remove(at: x)
                break
            }
        }
        
        if let price = Double(priceLabel.text!.suffix(4)) {
            
            totalPrice -= price
        }
        
        itemCount = (itemsOrdered.count + mealsOrdered.count)
        
        NotificationCenter.default.post(name: Notification.Name("itemRemoved"), object: nil)
    }
}


class OrderDataViewReusableView: UICollectionReusableView {
    
    @IBOutlet weak var lineLabel: UILabel!
    @IBOutlet weak var orderCountLabel: UILabel!
    
    
    @IBAction func viewCommentsPressed(_ sender: UIButton) {
        
        NotificationCenter.default.post(name: NSNotification.Name("viewCommentsPressed"), object: nil, userInfo: ["lineName": lineLabel.text!])
    }
}



