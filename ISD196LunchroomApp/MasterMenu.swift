//
//   MasterMenu.swift
//   ISD196LunchroomApp
//
//   Created by Sam on 12/12/18.
//   Copyright © 2018 district196.org. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore
import Foundation

// By default, all variables are global and accessible by any class, functions however are not, so the functions that we use to set these up have "static" in the declaration
var monthlyMenus = Dictionary<String,Month>()
var menuItems: [MenuItem] = [MenuItem]()
var aLaCarteItems: [MenuItem] = [MenuItem]()

class MasterMenu {
    
    static func downloadMenuItems() {
        
        // Checks to make sure that the dictionary hasn't already been created.
        if menuItems.count > 0 {
            return
        }
        
        let db = Firestore.firestore()
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
        
        // This function gets all of the documents in the Items collection in the database, and appends each one as its own MenuItem to the menuItems array
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
        
        // The list of month names that act as keys to get the database documents relating to each one
        let monthNames = ["September", "October", "November", "December", "January",
                          "February", "March", "April", "May", "June"]
        
        for month in monthNames {
            db.collection("menus").document(month)
                .collection("days").getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        print("Error getting documents: \(err)")
                    } else {
                        
                        // A temporary month object that to store the data and be appended to the dictionary
                        let tempMonth = Month(name: month)
                        
                        // A for each loop that goes through every day document that it downloaded
                        for document in querySnapshot!.documents {
                            
                            let tempDay = Day(day: document.documentID)
                            
                            // Converts the document to a dictionary so it's easier to use
                            let tempDict = document.data()
                            
                            // For each loop that goes through the lines and gets their data, then creates line objects, fills them with data, and appends them to the tempDay
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


