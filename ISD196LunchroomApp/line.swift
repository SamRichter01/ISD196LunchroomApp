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
    var price: Double
    var items = [String]()
    
    init (name: String, price: String) {
        self.name = name
        self.price = Double(price)!
    }
    
}
