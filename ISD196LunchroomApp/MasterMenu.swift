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
import UserNotifications

// By default, all variables are global and accessible by any class, functions however are not, so the functions that we use to set these up have "static" in the declaration
var monthlyMenus = Dictionary<String,Month>()
var aLaCarteMenu = Dictionary<String,MenuItem>()
var menuItems = Dictionary<String,MenuItem>()
var aLaCarteItems = Dictionary<String,MenuItem>()
var orderData = Dictionary<String, Dictionary<String, Dictionary<String,Int>>>()
var linePriorities = [String]()

class MasterMenu {
    
    static func downloadMenuItems() {
        
        print("downloading menu items")
        
        // Checks to make sure that the dictionary hasn't already been created.
        menuItems.removeAll()
        menuItems = Dictionary<String,MenuItem>()
        
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
                    
                    print(document.data().keys)
                    
                    menuItems[document.documentID] =
                        MenuItem(name: document.documentID,
                        description: (document.get("Description")) as! String)
                }
            }
        }
    }
    
    static func downloadALaCarteItems() {
        
        print("downloading a la carte items")
        
        aLaCarteItems.removeAll()
        aLaCarteItems = Dictionary<String,MenuItem>()
        
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
                    
                    aLaCarteItems[document.documentID] = (MenuItem(
                        name: document.documentID,
                        price: (document.get("Cost")) as! String))
                }
            }
        }
    }
    
    static func downloadALaCarteMenu() {
        
        print("downloading menu menu")
        
        aLaCarteMenu.removeAll()
        aLaCarteMenu = Dictionary<String,MenuItem>()
        
        let db = Firestore.firestore()
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
        
        db.collection("menus").document("A La Carte Menu")
            .collection("Items").getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        
                        aLaCarteMenu[document.documentID] = (MenuItem(
                            name: document.documentID,
                            price: (document.get("Cost")) as! String))
                    }
                }
        }
    }
    
    static func downloadMonthlyMenus() {
        
        print("downloading main menu")
        
        monthlyMenus.removeAll()
        monthlyMenus = Dictionary<String,Month>()
        
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        let db = Firestore.firestore()
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
        
        // The list of month names that act as keys to get the database documents relating to each one
        let monthNames = ["September", "October", "November", "December", "January",
                          "February", "March", "April", "May", "June"]
        let monthNums = [9, 10, 11, 12, 1, 2, 3, 4, 5, 6]
        
        for x in 0..<monthNames.count {
            
            let month = monthNames[x]
            
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
                                }
                                tempDay.lines[tempLine.name] = tempLine
                            }
                            
                        tempMonth.days[tempDay.day] = tempDay
                        monthlyMenus[tempMonth.name] = tempMonth
                          
                        let date = Date()
                        let calendar = Calendar.current
                        let currentMonth = calendar.component(.month, from: date)
                        let currentDay = calendar.component(.day, from: date)
                            
                        if (x > monthNums.firstIndex(of: currentMonth)!
                            || (monthNums.firstIndex(of: currentMonth) == x
                            && tempDay.day >= currentDay)) {
                            
                            setupNotifications(month: monthNums[x], day: tempDay.day)
                        }
                    }
                }
            }
        }
        
        db.collection("basicData").document("lines").getDocument { (document, err) in
            if let document = document, document.exists {
                
                let data = document.data()
                
                linePriorities = data!["lineList"] as! [String]
                
            } else {
                
                print("Document does not exist")
            }
        }
    }
    
    static func downloadOrderData() {
        
        print("downloading order data")
        
        orderData.removeAll()
        orderData = Dictionary<String, Dictionary<String, Dictionary<String,Int>>>()
        
        let db = Firestore.firestore()
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
        
        // The list of month names that act as keys to get the database documents relating to each one
        let monthNames = ["September", "October", "November", "December", "January",
                          "February", "March", "April", "May", "June"]
        
        for month in monthNames {
            db.collection("orders").document(month).collection("days").getDocuments
                { (querySnapshot, err) in
                    if let err = err {
                        print("Error getting documents: \(err)")
                    } else {
                        
                        var tempDict = Dictionary<String, Dictionary<String, Int>>()
                        // A for each loop that goes through every day document that it downloaded
                        for document in querySnapshot!.documents {
                            
                            var tempDoc = document.data()
                            
                            if let count = tempDoc["Order count"] {
                                //print("\(month) \(document.documentID) \(count)")
                            } else {
                                print("No order count for \(month) \(document.documentID)")
                            }
                            
                            tempDict[document.documentID] = tempDoc as? Dictionary<String, Int>
                        }
                        
                        orderData[month] = tempDict
                    }
            }
        }
    }
    
    static func setupNotifications (month: Int, day: Int) {
        
        let center = UNUserNotificationCenter.current()
        
        center.getNotificationSettings { (settings) in
            if settings.authorizationStatus == .authorized {
                
                //Notifications allowed
                
                let content = UNMutableNotificationContent()
                content.title = "Order Lunch"
                content.body = "Don't forget to order lunch today!"
                content.sound = UNNotificationSound.default()
                
                var dateInfo = DateComponents()
                    dateInfo.month = month
                    dateInfo.day = day
                    dateInfo.hour = 9
                    dateInfo.minute = 10
                    dateInfo.second = 0
                    dateInfo.timeZone = .current
                        
                    let trigger = UNCalendarNotificationTrigger(dateMatching: dateInfo, repeats: true)
                    let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                    center.add(request) { (error : Error?) in
                            
                    if let theError = error {
                        print(theError.localizedDescription)
                    } else {
                        print("Set reminder for: \(month)/\(day)")
                    }
                }
            }
        }
    }
}





