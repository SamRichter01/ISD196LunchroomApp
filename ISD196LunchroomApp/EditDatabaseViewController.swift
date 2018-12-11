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

class EditDatabaseViewController: UIViewController {
    
    @IBOutlet weak var sheetIdField: UITextField!
    @IBOutlet weak var createMonthButton: UIButton!
    @IBOutlet weak var updateMonthButton: UIButton!
    
    private let service = GTLRSheetsService()
    
    let spreadsheetId: String = "1BzwR51oDGJsW9VgSK0LvCaFMuRrE2W0Zbmkrzm_XFmo"
    
    lazy var db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        GIDSignIn.sharedInstance().scopes = [kGTLRAuthScopeSheetsDrive]
        service.rootURLString += "/"
        
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
        // Do any additional setup after loading the view.
    }

    @IBAction func backToMain(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "toMain", sender: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Display the data within the spreadsheet from the range
    // spreadsheet:
    // https://docs.google.com/spreadsheets/d/1BzwR51oDGJsW9VgSK0LvCaFMuRrE2W0Zbmkrzm_XFmo/edit#gid=0
    func getMenu() {
        
        let range = "'Monthly Menu'!A2:BM21"
        
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
        
        let month = Month(name: "This Month")
        
        // Add a new document in collection "cities"
        let menus = db.collection("menus")
        menus.document("month").setData(["name": "\(month.name)"]) { err in
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
            
            let dayRef = db.collection("menus").document("month").collection("days").document("\(day.day)")
            
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
    func updateMenu() {
        
        let range = "'Monthly Menu'!A2:BM21"
        
        let query = GTLRSheetsQuery_SpreadsheetsValuesGet.query(withSpreadsheetId: spreadsheetId, range: range)
        query.valueRenderOption = "FORMATTED_VALUE"
        service.authorizer = GIDSignIn.sharedInstance().currentUser.authentication.fetcherAuthorizer()
        service.executeQuery(query, delegate: self,
                             didFinish: #selector(updateItems(ticket:finishedWithObject:error:)))
    }
    
    // Process the response and display output
    @objc func updateItems(ticket: GTLRServiceTicket,
                            finishedWithObject result : GTLRSheets_ValueRange, error : NSError?) {
        
        if let error = error {
            return
        }
        
        let rows = result.values!
        
        if rows.isEmpty {
            return
        }
        
        let month = Month(name: "This Month")
        
        /* Add a new document in collection "cities"
        let menus = db.collection("menus")
        menus.document("month").updateData(["name": "\(month.name)"]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }
         */
        
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
            
            let dayRef = db.collection("menus").document("month").collection("days").document("\(day.day)")
            
            batch.updateData(["line 1": day.lines[0].items, "line 2": day.lines[1].items,
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
    
    @IBAction func createMonthPressed(_ sender: UIButton) {
        getMenu()
    }
    
    @IBAction func updateMonthPressed(_ sender: UIButton) {
        updateMenu()
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
