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

class Order {
    
    func getDate() {
        
        let date = Date()
        let calendar = Calendar.current
        
        var monthName = "September"
        var day = 1
        
        day = calendar.component(.day, from: date)
        let month = calendar.component(.month, from: date)
        let year = calendar.component(.year, from: date)
        monthName = monthToString(month: month)
        
        while (monthlyMenus[monthName]!.days[day] == nil) {
            if (day >= calendar.range(of: .day, in: .month, for: date)!.count) {
                if (month == 12) {
                    monthName = monthToString(month: 1)
                } else {
                    monthName = monthToString(month: month + 1)
                }
                day = 0
            }
            day += 1
        }
        
        orderDate = "\(monthName) \(day), \(year)"
        return
    }
    
    func monthToString (month: Int) -> String {
        
        var monthName = "September"
        
        switch month {
        case 9 :
            monthName = "September"
        case 10 :
            monthName = "October"
        case 11 :
            monthName = "November"
        case 12 :
            monthName = "December"
        case 1 :
            monthName = "January"
        case 2 :
            monthName = "February"
        case 3 :
            monthName = "March"
        case 4 :
            monthName = "April"
        case 5 :
            monthName = "May"
        case 6 :
            monthName = "June"
        default :
            break
        }
        
        return monthName
    }
}
