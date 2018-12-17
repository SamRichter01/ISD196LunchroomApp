//
//  EditDatabaseViewController.swift
//  ISD196LunchroomApp
//
//  Created by Sam on 12/11/18.
//  Copyright © 2018 district196.org. All rights reserved.
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
    
    private let service = GTLRSheetsService()
    
    var spreadsheetId: String = "1BzwR51oDGJsW9VgSK0LvCaFMuRrE2W0Zbmkrzm_XFmo"
    
    lazy var db = Firestore.firestore()
    
    let pickerData = ["September", "October", "November", "December", "January",
                      "February", "March", "April", "May", "June"]
    
    var days = [[String]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        sheetIdField.text = spreadsheetId
        
        service.rootURLString += "/"
        
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
        
        monthPicker.delegate = self
        monthPicker.dataSource = self
        
        // Do any additional setup after loading the view.
    }

    @IBAction func backToMain(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "toMain", sender: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // The number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    // The data to return fopr the row and component (column) that's being passed in
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    // Display the data within the spreadsheet from the range
    // spreadsheet:
    // https://docs.google.com/spreadsheets/d/1BzwR51oDGJsW9VgSK0LvCaFMuRrE2W0Zbmkrzm_XFmo/edit#gid=0
    func getMenu() {
        
        let range = "'Monthly Menu'!A2:BM21"
        
        if (sheetIdField.text != nil) {
            if ((sheetIdField.text?.count)! >= spreadsheetId.count) {
                spreadsheetId = sheetIdField.text!
            }
        }
        
        let query = GTLRSheetsQuery_SpreadsheetsValuesGet.query(withSpreadsheetId: spreadsheetId, range: range)
        query.valueRenderOption = "FORMATTED_VALUE"
        service.authorizer = GIDSignIn.sharedInstance().currentUser.authentication.fetcherAuthorizer()
        service.executeQuery(query, delegate: self,
                             didFinish: #selector(importItems(ticket:finishedWithObject:error:)))
    }
    
    // Process the response and display output
    @objc func importItems(ticket: GTLRServiceTicket,
                            finishedWithObject result : GTLRSheets_ValueRange, error : NSError?) {
        
        if let error = error {
            return
        }
        
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
        
        let batch = db.batch()
        
        for x in 0..<days.count {
            
            if (days[x][0].contains(selectedMonth)) {
                
                let week = Int(days[x][1])!
                let rotationDay = Int(days[x][2])!
                let startDate = Int(days[x][3])!
                let numberOfDays = Int(days[x][4])!
                var menuIndex = (((week - 1) * 5) + (rotationDay) - 1)
                
                for y in startDate..<(startDate + numberOfDays) {
                    
                    let day = Day(day: "\(y)")
                    
                    for i in 2..<rows[menuIndex].count {
                        
                        if (rows[menuIndex][i] as! String).contains("Line") {
                            let line = Line(name: (rows[menuIndex][i] as! String), price: (rows[menuIndex][i+1] as! String))
                            for z in i..<i+8 {
                                if !(rows[menuIndex][z] as! String).contains("none") {
                                    line.items.append(rows[menuIndex][z] as! String)
                                }
                            }
                            day.lines[line.name] = line
                        }
                    }
            
                    menuIndex += 1
                    
                    let dayRef = db.collection("menus").document(selectedMonth)
                        .collection("days").document("\(day.day)")
                    
                    batch.setData(["Line 1": day.lines["Line: 1"]!.items,
                                   "Line 2": day.lines["Line: 2"]!.items,
                                   "Line 3": day.lines["Line: 3"]!.items,
                                   "Line 4": day.lines["Line: 4"]!.items,
                                   "Soup Bar": day.lines["Line: Soup Bar"]!.items,
                                   "Farm 2 School": day.lines["Line: Farm 2 School"]!.items,
                                   "Sides": day.lines["Line: Sides"]!.items],
                                  forDocument: dayRef)
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
    }
    
    // Display the data within the spreadsheet from the range
    // spreadsheet:
    // https://docs.google.com/spreadsheets/d/1BzwR51oDGJsW9VgSK0LvCaFMuRrE2W0Zbmkrzm_XFmo/edit#gid=0
    func getMenuItems() {
        
        let range = "'Daily Menu'!A2:A106"
        
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
        
        if let error = error {
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
            
            batch.setData(["Item index": "\(x)"], forDocument: dayRef)
        }
        
        batch.commit() { err in
            if let err = err {
                print("Error writing batch \(err)")
            } else {
                print("Batch write succeeded.")
            }
        }
    }
    
    // Display the data within the spreadsheet from the range
    // spreadsheet:
    // https://docs.google.com/spreadsheets/d/1BzwR51oDGJsW9VgSK0LvCaFMuRrE2W0Zbmkrzm_XFmo/edit#gid=0
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
        
        if let error = error {
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
        
        let batch = db.batch()
        
        for x in 0..<rows.count {
            
            let dayRef = db.collection("menus").document("A La Carte Items")
                .collection("Items").document("\(rows[x][0])")
            
            batch.setData(["Item index": "\(x)", "Cost": rows[x][1]], forDocument: dayRef)
        }
        
        batch.commit() { err in
            if let err = err {
                print("Error writing batch \(err)")
            } else {
                print("Batch write succeeded.")
            }
        }
    }
    
    @IBAction func createMonthPressed(_ sender: UIButton) {
        getMenu()
    }
    
    @IBAction func updateListPressed(_ sender: UIButton) {
        getMenuItems()
    }
    
    @IBAction func updateALaCartePressed(_ sender: UIButton) {
        getALaCarteItems()
    }
    
    // Display the data within the spreadsheet from the range
    // spreadsheet:
    // https://docs.google.com/spreadsheets/d/1BzwR51oDGJsW9VgSK0LvCaFMuRrE2W0Zbmkrzm_XFmo/edit#gid=0
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
        
        if let error = error {
            return
        }
        
        days = result.values as! [[String]]
        
        if days.isEmpty {
            return
        }
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
