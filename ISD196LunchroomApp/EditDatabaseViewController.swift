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
        
        let month = Month(name: "\(pickerData[monthPicker.selectedRow(inComponent: 0)])")
        
        // Add a new document in collection "cities"
        let menus = db.collection("menus")
        menus.document(month.name).setData(["name": "\(month.name)"]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }
        
        let batch = db.batch()
        
        for x in 0..<rows.count {
            
            var day = Day(day: x+1)
            
            for y in 2..<rows[x].count {
                
                if (rows[x][y] as! String).contains("Line") {
                    let line = Line(name: (rows[x][y] as! String), price: (rows[x][y+1] as! String))
                    for z in y+1..<y+8 {
                        if !(rows[x][z] as! String).contains("none") {
                            line.items.append(rows[x][z] as! String)
                        }
                    }
                    day.lines.append(line)
                }
            }
            
            month.days.append(day)
            
            let dayRef = db.collection("menus").document(month.name)
                .collection("days").document("\(day.day)")
            
            batch.setData(["line 1": day.lines[0].items, "line 2": day.lines[1].items,
                           "line 3": day.lines[2].items, "line 4": day.lines[3].items,
                           "Soup Bar": day.lines[4].items, "Farm 2 School": day.lines[5].items,
                           "Sides": day.lines[6].items], forDocument: dayRef)
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
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
