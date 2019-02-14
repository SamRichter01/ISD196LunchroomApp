//
//  Month.swift
//  ISD196LunchroomApp
//
//  Created by Sam on 12/11/18.
//  Copyright © 2018 district196.org. All rights reserved.
//

import Foundation

class Month {
    
    var name: String
    var days = Dictionary<Int,Day>()
    
    init (name: String) {
        self.name = name
    }
}
