//
//  Line.swift
//  ISD196LunchroomApp
//
//  Created by Sam on 12/11/18.
//  Copyright © 2018 district196.org. All rights reserved.
//

import Foundation

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
