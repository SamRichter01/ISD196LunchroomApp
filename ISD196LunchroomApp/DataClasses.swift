//
//  DataClasses.swift
//  ISD196LunchroomApp
//
//  Created by Sam on 5/13/19.
//  Copyright © 2019 district196.org. All rights reserved.
//

import Foundation

class Month {
    
    var name: String
    var days = Dictionary<Int,Day>()
    
    init (name: String) {
        self.name = name
    }
}


class Day {
    
    var day: Int
    var lines = Dictionary<String,Line>()
    
    init (day: String) {
        self.day = Int(day)!
    }
}


class Line {
    
    var name: String
    var price: String
    var priority = 0
    var items = [String]()
    
    init (name: String, price: String) {
        self.name = name
        self.price = price
    }
    
    func itemsToString () -> String {
        
        var str = ""
        
        for x in 0..<items.count {
            
            if x < items.count - 1 {
                
                str.append("\(items[x]),")
                
            } else {
                
                str.append("\(items[x])")
            }
        }
        
        return str
    }
    
    static func stringToItems (str: String) -> [String] {
        
        return str.components(separatedBy: ",")
    }
}


class MenuItem {
    
    var name: String
    var price: String
    var description: String
    
    init(name: String, description: String) {
        self.name = name
        self.description = description
        price = "$0"
    }
    
    init(name: String, price: String)
    {
        self.name = name
        self.price = price
        self.description = ""
    }
}


