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
    var itemType: String = "";
    var name: String = "";
    var price: Double = 0.0;
    var description: String = "";
    var ingredients: String = "";
    
    init(iT: String, n: String, p: Double, d: String, i: String)
    {
        itemType = iT
        name = n
        price = p
        description = d
        ingredients = i
    }
}
