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
    var name: String
    var price: String
    var description: String
    //var ingredients: String
    
    
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
