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

var monthlyMenus: [Month] = [Month]()
var menuItems: [MenuItem] = [MenuItem]()
var aLaCarteItems: [MenuItem] = [MenuItem]()

class MasterMenu {
    
    static func downloadMenuItems() {
        
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
                            
                            for x in 1..<8 {
                                
                                let lineDoc = (document.get("\(x)") as! [String])
                                
                                let tempLine = Line(
                                    name: lineDoc[0],
                                    price: lineDoc[1])
                                
                                if lineDoc.count > 3 {
                                    
                                    for y in 2..<lineDoc.count {
                                        
                                        tempLine.items.append(lineDoc[y])
                                    }
                                }
                                tempDay.lines.append(tempLine)
                            }
                            tempMonth.days.append(tempDay)
                            monthlyMenus.append(tempMonth)
                    }
                }
            }
        }
    }
}


