//
// EditDatabaseViewController.swift
// ISD196LunchroomApp
//
// Created by Sam on 12/11/18.
// Copyright © 2018 district196.org. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore
import GoogleAPIClientForREST
import GoogleSignIn

class EditDatabaseViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var sheetIdField: UITextField!
    @IBOutlet weak var createMonthButton: UIButton!
    @IBOutlet weak var monthPicker: UIPickerView!
    @IBOutlet weak var updateItemsButton: UIButton!
    @IBOutlet weak var updateALaCarteButton: UIButton!
    @IBOutlet weak var editALaCarteButton: UIButton!
    @IBOutlet weak var editMenuItemsButton: UIButton!
    
    // A service object that acts like a client for the sheets api
    private let service = GTLRSheetsService()
    
    // The default spreadsheet ID we're using, copied from the URL
    var spreadsheetId: String = "1BzwR51oDGJsW9VgSK0LvCaFMuRrE2W0Zbmkrzm_XFmo"
    
    // The database reference we're using, the lazy tag ensures that the variable is only created the first time it's used, instead of when the screen loads.
    lazy var db = Firestore.firestore()
    
    let pickerData = ["September", "October", "November", "December", "January",
                      "February", "March", "April", "May", "June"]
    
    // The two dimensional array of valid school days used to create the monthly menus
    var days = [[String]]()
    
    var editingType = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        sheetIdField.text = spreadsheetId
        
        // I dunno what this does, or how to fix it any other way, but the app crashes without it because the service object has a bad default URL
        service.rootURLString += "/"
        
        // Setting up the database
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
        
        // Establishing EditDatabaseViewController as the class from which handles the monthpicker
        monthPicker.delegate = self
        monthPicker.dataSource = self
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func backPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func editALaCartePressed(_ sender: UIButton) {
        
        editingType = "aLaCarte"
        
        performSegue(withIdentifier: "editItemsPressed", sender: self)
    }
    
    @IBAction func editMenuItemsPressed(_ sender: UIButton) {
        
        editingType = "mainMenu"
        
        performSegue(withIdentifier: "editItemsPressed", sender: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "editItemsPressed" {
            
            let editItemListsViewController = segue.destination as! EditItemListsViewController
            
            editItemListsViewController.editingType = editingType
            
        }
    }
    
    // The number of columns in the month picker
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // The number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    // The data to return for the row and component (column) that's being passed in
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    // Display the data within the spreadsheet from the range
    // spreadsheet:
    // https:// docs.google.com/spreadsheets/d/1BzwR51oDGJsW9VgSK0LvCaFMuRrE2W0Zbmkrzm_XFmo/edit#gid=0
    func getMenu() {
        
        // The range, including the name of the spreadsheet, and the section of cells we're getting
        let range = "'Monthly Menu'!A2:BM21"
        
        // If the field to input a new sheet ID isn't blank, use that new ID
        if (sheetIdField.text != nil) {
            if ((sheetIdField.text?.count)! >= spreadsheetId.count) {
                spreadsheetId = sheetIdField.text!
            }
        }
        
        // A query object that the service object executes, certain types of queries read or write, and they all contain a range of cells to read.
        let query = GTLRSheetsQuery_SpreadsheetsValuesGet.query(withSpreadsheetId: spreadsheetId, range: range)
        
        // Makes it so that all the data is returned as a string
        query.valueRenderOption = kGTLRSheetsValueRenderOptionFormattedValue
        
        // The authorizer, that lets the google servers know which user is making the query
        service.authorizer = GIDSignIn.sharedInstance().currentUser.authentication.fetcherAuthorizer()
        
        // Executes the query and calls the importItems function to handle the data
        service.executeQuery(query, delegate: self,
                             didFinish: #selector(importItems(ticket:finishedWithObject:error:)))
    }
    
    // Process the response and display output
    @objc func importItems(ticket: GTLRServiceTicket,
                            finishedWithObject result : GTLRSheets_ValueRange, error : NSError?) {
        
        NotificationCenter.default.post(name: Notification.Name("itemsLoaded"), object: nil)
        
        if let _ = error {
            return
        }
        
        // Creates a 2d array with the values the query returned
        let rows = result.values!
        
        if rows.isEmpty {
            return
        }
        
        let selectedMonth = pickerData[monthPicker.selectedRow(inComponent: 0)]
        
        getSchoolDays()
        
        // Add a new document in collection "cities"
        let menus = db.collection("menus")
        menus.document(selectedMonth).setData(["name": selectedMonth]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }
        
        let orders = db.collection("orders")
        orders.document(selectedMonth).setData([:]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }
        
        let feedback = db.collection("feedback")
        feedback.document(selectedMonth).setData([:]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }
        
        // A batch update, it lets us set multiple parts of the database with a single commit
        let batch = db.batch()
        
        // For x in the array of school days that getSchoolDays created
        for x in 0..<days.count {
            
            // Check out how the school days spreadsheet is layed out, this checks if the a row in column A corresponds to the user's selected month, and then uses the data in that row to fill in the valid school days
            if (days[x][0].contains(selectedMonth)) {
                
                // The week 1 through 4 in the four week menu rotation for this specific week
                let week = Int(days[x][1])!
                
                // The day in the rotation that the week starts on, mondays are 1, tuesdays are 2, and so on
                let rotationDay = Int(days[x][2])!
                
                // The day of the month of the first day of the week
                let startDate = Int(days[x][3])!
                
                // The number of days in the week
                let numberOfDays = Int(days[x][4])!
                
                // Since the days in the four week rotation is stored in a 20 row 2d array, this figures out which day should be used
                var menuIndex = (((week - 1) * 5) + (rotationDay) - 1)
                
                for y in startDate..<(startDate + numberOfDays) {
                    
                    // Creates a day object and sets the day to the day of the month
                    let day = Day(day: "\(y)")
                    
                    // Steps through the row of data at the menu index it calculated earlier
                    for i in 2..<rows[menuIndex].count {
                        
                        // If the word line is present at the index, it creates a line object with the name, price, and items. All of which are at set points in the array.
                        let tempLineName = rows[menuIndex][i] as! String
                        
                        if isLine(name: tempLineName) {
                            print(tempLineName)
                            
                            let line = Line(name: tempLineName, price: (rows[menuIndex][i+1] as! String))
                            
                            for z in i..<i+8 {
                                
                                if !(rows[menuIndex][z] as! String).contains("none") {
                                    
                                    line.items.append(rows[menuIndex][z] as! String)
                                }
                            }
                            
                            // The path in the database to the corresponding day that's being created/edited
                            let dayRef = db.collection("menus").document(selectedMonth)
                                .collection("days").document("\(day.day)")
                            
                            let orderDayRef = db.collection("orders").document(selectedMonth)
                                .collection("days").document("\(day.day)")
                            
                            let feedbackDayRef = db.collection("feedback").document(selectedMonth)
                                .collection("days").document("\(day.day)")
                            
                            // Adds the data from the line to the batch query
                            batch.setData(["\(line.name)": line.items], forDocument: dayRef, merge: true)
                            
                            // Adds the document for orders to the batch
                            batch.setData(["Order count": 0], forDocument: orderDayRef)
                            
                            // Adds the document for orders to the batch
                            batch.setData(["Comment count": 0], forDocument: feedbackDayRef)
                            
                            // Adds the line it created to the dictionary stored by the current day
                            day.lines[line.name] = line
                        }
                    }
            
                    menuIndex += 1
                }
            }
        }
       
        batch.commit() { err in
            if let err = err {
                print("Error writing batch \(err)")
            } else {
                print("Batch write succeeded.")
            }
        }
        NotificationCenter.default.post(name: Notification.Name("menuUpdated"), object: nil)
    }
    
    // The comments from the code in getMenu should explain all the functions of this function
    // https:// docs.google.com/spreadsheets/d/1BzwR51oDGJsW9VgSK0LvCaFMuRrE2W0Zbmkrzm_XFmo/edit#gid=0
    func getMenuItems() {
        
        let range = "'Daily Menu'!A2:B106"
        
        if (sheetIdField.text != nil) {
            if ((sheetIdField.text?.count)! >= spreadsheetId.count) {
                spreadsheetId = sheetIdField.text!
            }
        }
        
        let query = GTLRSheetsQuery_SpreadsheetsValuesGet.query(withSpreadsheetId: spreadsheetId, range: range)
        query.valueRenderOption = "FORMATTED_VALUE"
        service.authorizer = GIDSignIn.sharedInstance().currentUser.authentication.fetcherAuthorizer()
        service.executeQuery(query, delegate: self,
                             didFinish: #selector(importMenuItems(ticket:finishedWithObject:error:)))
    }
    
    // Process the response and display output
    @objc func importMenuItems(ticket: GTLRServiceTicket,
                           finishedWithObject result : GTLRSheets_ValueRange, error : NSError?) {
        
        NotificationCenter.default.post(name: Notification.Name("itemsLoaded"), object: nil)
        
        if let _ = error {
            return
        }
        
        let rows = result.values!
        
        if rows.isEmpty {
            return
        }
        
        // Add a new document in collection "cities"
        let menus = db.collection("menus")
        menus.document("Menu Items").setData(["nunber of items": "\(rows.count)"]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }
        
        let batch = db.batch()
        
        for x in 0..<rows.count {
            
            let dayRef = db.collection("menus").document("Menu Items")
                .collection("Items").document("\(rows[x][0])")
            
            batch.setData(["Description": rows[x][1]], forDocument: dayRef)
        }
        
        batch.commit() { err in
            if let err = err {
                print("Error writing batch \(err)")
            } else {
                print("Batch write succeeded.")

            }
        }
        NotificationCenter.default.post(name: Notification.Name("menuUpdated"), object: nil)
    }
    
    // The comments from the code in getMenu should explain all the functions of this function
    // https:// docs.google.com/spreadsheets/d/1BzwR51oDGJsW9VgSK0LvCaFMuRrE2W0Zbmkrzm_XFmo/edit#gid=0
    func getALaCarteItems() {
        
        let range = "'A La Carte Menu'!A2:B83"
        
        if (sheetIdField.text != nil) {
            if ((sheetIdField.text?.count)! >= spreadsheetId.count) {
                spreadsheetId = sheetIdField.text!
            }
        }
        
        let query = GTLRSheetsQuery_SpreadsheetsValuesGet.query(withSpreadsheetId: spreadsheetId, range: range)
        query.valueRenderOption = "FORMATTED_VALUE"
        service.authorizer = GIDSignIn.sharedInstance().currentUser.authentication.fetcherAuthorizer()
        service.executeQuery(query, delegate: self,
                             didFinish: #selector(importALaCarteItems(ticket:finishedWithObject:error:)))
    }
    
    // Process the response and display output
    @objc func importALaCarteItems(ticket: GTLRServiceTicket,
                               finishedWithObject result : GTLRSheets_ValueRange, error : NSError?) {
        
        NotificationCenter.default.post(name: Notification.Name("itemsLoaded"), object: nil)
        
        if let _ = error {
            return
        }
        
        let rows = result.values!
        
        if rows.isEmpty {
            return
        }
        
        // Add a new document in collection "cities"
        let menus = db.collection("menus")
        menus.document("A La Carte Items").setData(["number of items": "\(rows.count)"]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }
        menus.document("A La Carte Menu").setData(["number of items": "\(rows.count)"]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }
        
        let batch = db.batch()
        
        for x in 0..<rows.count {
            
            var dayRef = db.collection("menus").document("A La Carte Items")
                .collection("Items").document("\(rows[x][0])")
            
            batch.setData(["Cost": rows[x][1]], forDocument: dayRef)
            
            dayRef = db.collection("menus").document("A La Carte Menu")
                .collection("Items").document("\(rows[x][0])")
            
            batch.setData(["Cost": rows[x][1]], forDocument: dayRef)
        }
        
        batch.commit() { err in
            if let err = err {
                print("Error writing batch \(err)")
            } else {
                print("Batch write succeeded.")
            }
        }
        NotificationCenter.default.post(name: Notification.Name("menuUpdated"), object: nil)
    }
    
    @IBAction func createMonthPressed(_ sender: UIButton) {
        
        let alertController = UIAlertController(title: "Upload Menu Rotation", message: "Are you sure you want to set the daily menus to the rotation from the spreadsheet?", preferredStyle: UIAlertControllerStyle.alert)
        
        alertController.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.default, handler: nil))
        
        alertController.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: { (action: UIAlertAction!) in
            self.performSegue(withIdentifier: "displayUpdatePopup", sender: nil)
            self.getMenu()}))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func updateListPressed(_ sender: UIButton) {
        
        let alertController = UIAlertController(title: "Upload Menu Items", message: "Are you sure you want to upload the Menu Items from the spreadsheet?", preferredStyle: UIAlertControllerStyle.alert)
        
        alertController.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.default, handler: nil))
        
        alertController.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: { (action: UIAlertAction!) in
            self.performSegue(withIdentifier: "displayUpdatePopup", sender: nil)
            self.getMenuItems()}))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func updateALaCartePressed(_ sender: UIButton) {
        
        let alertController = UIAlertController(title: "Upload A La Carte Items", message: "Are you sure you want to upload the A La Carte items from the spreadsheet?", preferredStyle: UIAlertControllerStyle.alert)
        
        alertController.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.default, handler: nil))
        
        alertController.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: { (action: UIAlertAction!) in
            self.performSegue(withIdentifier: "displayUpdatePopup", sender: nil)
            self.getALaCarteItems()}))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    // Gets the spreadsheet containing the days of the month for getMenu to use, and stores them in a global array
    // https:// docs.google.com/spreadsheets/d/1BzwR51oDGJsW9VgSK0LvCaFMuRrE2W0Zbmkrzm_XFmo/edit#gid=0
    func getSchoolDays() {
        
        let range = "'School Days'!A2:E43"
        
        let defaultSpreadsheetId: String = "1BzwR51oDGJsW9VgSK0LvCaFMuRrE2W0Zbmkrzm_XFmo"
        
        let query = GTLRSheetsQuery_SpreadsheetsValuesGet.query(withSpreadsheetId: defaultSpreadsheetId, range: range)
        query.valueRenderOption = "FORMATTED_VALUE"
        service.authorizer = GIDSignIn.sharedInstance().currentUser.authentication.fetcherAuthorizer()
        service.executeQuery(query, delegate: self,
                             didFinish: #selector(createCalendar(ticket:finishedWithObject:error:)))
    }
    
    // Process the response and display output
    @objc func createCalendar(ticket: GTLRServiceTicket,
                           finishedWithObject result : GTLRSheets_ValueRange, error : NSError?) {
        
        if let _ = error {
            return
        }
        
        days = result.values as! [[String]]
        
        if days.isEmpty {
            return
        }
    }
    
    func isLine (name: String) -> Bool {
        let lineList = ["Line 1", "Line 2", "Line 3", "Line 4",
                        "Sides", "Farm 2 School", "Soup Bar"]
        for x in 0..<lineList.count {
            if name == lineList[x] {
                return true
            }
        }
        return false
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}
