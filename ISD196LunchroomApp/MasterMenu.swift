//
//  MasterMenu.swift
//  ISD196LunchroomApp
//
//  Created by Sam on 12/12/18.
//  Copyright © 2018 district196.org. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore
import Foundation

var monthlyMenus = Dictionary<String,Month>()
var menuItems: [MenuItem] = [MenuItem]()
var aLaCarteItems: [MenuItem] = [MenuItem]()

class MasterMenu {
    
    static func downloadMenuItems() {
        
        if menuItems.count > 0 {
            return
        }
        
        let db = Firestore.firestore()
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
        
        db.collection("menus").document("Menu Items")
            .collection("Items").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    menuItems.append(MenuItem.init(
                        index: (document.get("Item index")) as! String,
                        name: document.documentID))
                }
                /*
                for x in 0..<aLaCarteItems.count {
                    print("Added menu item with index: \(aLaCarteItems[x].index)")
                }
                */
            }
        }
    }
    
    static func downloadALaCarteItems() {
        
        if aLaCarteItems.count > 0 {
            return
        }
        
        let db = Firestore.firestore()
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
        
        db.collection("menus").document("A La Carte Items")
            .collection("Items").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    aLaCarteItems.append(MenuItem.init(
                        index: (document.get("Item index")) as! String,
                        name: document.documentID,
                        price: (document.get("Cost")) as! String))
                }
                /*
                for x in 0..<aLaCarteItems.count {
                    print("Added a la carte item with index: \(aLaCarteItems[x].index)")
                }
                */
            }
        }
    }
    
    static func downloadMonthlyMenus() {
        
        if monthlyMenus.count > 0 {
            return
        }
        
        let db = Firestore.firestore()
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
        
        let monthNames = ["September", "October", "November", "December", "January",
                          "February", "March", "April", "May", "June"]
        
        for month in monthNames {
            db.collection("menus").document(month)
                .collection("days").getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        print("Error getting documents: \(err)")
                    } else {
                        
                        let tempMonth = Month(name: month)
                        
                        for document in querySnapshot!.documents {
                            
                            let tempDay = Day(day: document.documentID)
                            let tempDict = document.data()
                            
                            for (index, lineArray) in tempDict {
                                
                                let lineItems = lineArray as! [String]
                                
                                let tempLine = Line (
                                    name: index,
                                    price: lineItems[1])
                                
                                if lineItems.count > 2 {
                                    
                                    for y in 2..<lineItems.count {
                                        
                                        tempLine.items.append(lineItems[y])
                                    }
                                    tempDay.lines[tempLine.name] = tempLine
                                }
                            }
                            tempMonth.days[tempDay.day] = tempDay
                            monthlyMenus[tempMonth.name] = tempMonth
                    }
                }
            }
        }
    }
}


