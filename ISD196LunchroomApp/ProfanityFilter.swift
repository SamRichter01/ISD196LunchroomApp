//
//  SheckWest.swift
//  ISD196LunchroomApp
//
//  Created by Sam on 2/28/19.
//  Copyright © 2019 district196.org. All rights reserved.
//

import Foundation

var naughtyWords = [String]()

class ProfanityFilter {
    
    static func loadData () {
        
        if let filepath = Bundle.main.path(forResource: "Profanity", ofType: "txt") {
            do {
                
                var contents = try String(contentsOfFile: filepath)
            
                contents = contents.replacingOccurrences(of: " ", with: "")
                contents = contents.replacingOccurrences(of: "\"", with: "")
                contents = contents.replacingOccurrences(of: "\t", with: "")
                contents = contents.replacingOccurrences(of: "\n", with: "")
                
                naughtyWords = contents.components(separatedBy: ",")
                
            } catch {
                
                print("Could not load file")
                return
            }
        } else {
            
            print("No such file exists")
            return
        
        }
    }
    
    static func removeProfanity (str: String) -> String {
        
        var newString = str.lowercased()
        
        for word in naughtyWords {
            
            let censor = "".padding(toLength: word.count, withPad: "*", startingAt: 0)
            
            newString = newString.replacingOccurrences(of: word, with: censor)
        }
        
        return newString
    }
}
