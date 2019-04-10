//
//  Order.swift
//  ISD196LunchroomApp
//
//  Created by Sam on 1/3/19.
//  Copyright © 2019 district196.org. All rights reserved.
//

import Foundation

//var previousOrder = [String]()

var itemsOrdered = [MenuItem]()
var mealsOrdered = [Line]()
var previousItems = [MenuItem]()
var previousMeals = [Line]()

/*
var mealOrdered = [String]()
var mealName = ""
var mealPrice = ""
 */
var totalPrice = 0.0
//var haveOrdered = false
var itemCount = 0

class Order {
    
    static func deleteOrder () {
        itemsOrdered.removeAll()
        mealsOrdered.removeAll()
        totalPrice = 0.0
        itemCount = 0
    }
    
    static func saveOrder () {
        previousItems.removeAll()
        previousMeals.removeAll()
        
        previousItems = itemsOrdered
        previousMeals = mealsOrdered
        
        itemCount = 0
    }
    
    static func reloadItemCount () {
        
        itemCount = 0
        
        itemCount = (itemsOrdered.count + mealsOrdered.count)
        
        NotificationCenter.default.post(name: Notification.Name("itemOrdered"), object: nil)
    }
}
