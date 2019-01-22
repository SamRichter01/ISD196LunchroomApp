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

class Order {
    
    static func deleteOrder () {
        itemsOrdered.removeAll()
        mealOrdered.removeAll()
        mealName = ""
        mealPrice = ""
        orderDate = ""
        totalPrice = 0.0
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
    }
}
