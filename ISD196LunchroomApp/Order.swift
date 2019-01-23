//
//  Order.swift
//  ISD196LunchroomApp
//
//  Created by Sam on 1/3/19.
//  Copyright © 2019 district196.org. All rights reserved.
//

import Foundation

var previousOrder = [String]()
var itemsOrdered = [MenuItem]()
var mealOrdered = [String]()
var mealName = ""
var mealPrice = ""
var orderDate = ""
var totalPrice = 0.0
var haveOrdered = false
var itemCount = 0

class Order {
    
    static func deleteOrder () {
        itemsOrdered.removeAll()
        mealOrdered.removeAll()
        mealName = ""
        mealPrice = ""
        orderDate = ""
        totalPrice = 0.0
        itemCount = 0
    }
    
    static func removePrevious () {
        previousOrder.removeAll()
    }
    
    static func saveOrder () {
        
        for item in itemsOrdered {
            previousOrder.append(item.name)
        }
        if mealName != "" {
            previousOrder.append(mealName)
        }
        haveOrdered = true
        itemCount = 0
    }
    
    static func reloadItemCount () {
        
        itemCount = 0
        
        for _ in 0..<itemsOrdered.count {
            itemCount += 1
        }
        if mealName != "" {
            itemCount += 1
        }
        
        NotificationCenter.default.post(name: Notification.Name("itemOrdered"), object: nil)
    }
}
