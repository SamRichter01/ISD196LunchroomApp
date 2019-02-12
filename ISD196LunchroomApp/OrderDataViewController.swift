//
//  OrderDataViewController.swift
//  ISD196LunchroomApp
//
//  Created by Sam on 2/1/19.
//  Copyright © 2019 district196.org. All rights reserved.
//

import UIKit

class OrderDataViewController: UIViewController {

    @IBOutlet weak var totalOrderGraph: GraphView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        var tempData = [Int]()
        var tempMonths = [String]()
        var tempDays = [String]()
        /*
        for i in 0...3 {
            
            let dailyData = orderData["January"]!["\(22 + i)"]!
            
            tempData.append(dailyData["Order count"]!)
        }
        */
        
        let today = Date()
        let calendar = Calendar.current
        
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("MM/dd")
        
        for i in stride(from: 8, to: -1, by: -1) {
            if let date = calendar.date(byAdding: .day, value: -i, to: today) {
                
                formatter.setLocalizedDateFormatFromTemplate("MMMM")
                var month = formatter.string(from: date)
                
                formatter.setLocalizedDateFormatFromTemplate("d")
                var day = formatter.string(from: date)
                
                if let dailyData = orderData[month]![day] {
                
                    tempData.append(dailyData["Order count"]!)
                    
                    formatter.setLocalizedDateFormatFromTemplate("dd")
                    day = formatter.string(from: date)
                    
                    tempDays.append(day)
                    
                    formatter.setLocalizedDateFormatFromTemplate("MM")
                    month = formatter.string(from: date)
                    
                    tempMonths.append(month)
                    
                }
            }
        }

        /*
        totalOrderGraph.graphPoints = tempData
        totalOrderGraph.months = tempMonths
        totalOrderGraph.days = tempDays
         */
        // Do any additional setup after loading the view.
    }
    
    @IBAction func backToMenuPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
