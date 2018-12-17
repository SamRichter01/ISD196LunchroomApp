//
//  Day.swift
//  ISD196LunchroomApp
//
//  Created by Sam on 12/11/18.
//  Copyright © 2018 district196.org. All rights reserved.
//

import Foundation

class Day {
    
    var day: Int
    var lines = Dictionary<String,Line>()
    
    init (day: String) {
        self.day = Int(day)!
    }
    
}
