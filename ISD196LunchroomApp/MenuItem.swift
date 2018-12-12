//
//  MenuItem.swift
//  ISD196LunchroomApp
//
//  Created by Josh on 12/12/18.
//  Copyright © 2018 district196.org. All rights reserved.
//

import Foundation

class MenuItem
{
    var index: Int
    var name: String
    var price: Double
    /*
    var description: String
    var ingredients: String
    */
    
    init(index: String, name: String) {
        self.index = Int(index)!
        self.name = name
        price = 0.0
    }
    
    init(index: String, name: String, price: String)
    {
        self.index = Int(index)!
        self.name = name
        self.price = Double(price)!
    }
}
