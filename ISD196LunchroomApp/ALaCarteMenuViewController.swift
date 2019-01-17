//
//  ALaCarteMenuViewController.swift
//  ISD196LunchroomApp
//
//  Created by SCHOEPKE, SAMUEL on 1/15/19.
//  Copyright © 2019 district196.org. All rights reserved.
//

import UIKit

class ALaCarteMenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var matchingItems = [MenuItem]()
    
    
    
    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var aLaCarteMenuTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        aLaCarteMenuTableView.dataSource = self
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func returnToMainMenu(_ sender: UIButton) {
        performSegue(withIdentifier: "returnFromALaCarteMenu", sender: self)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        matchingItems = aLaCarteItems
        
        if matchingItems.count >= 1 {
            
            return matchingItems.count
            
        } else {
            
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "aLaCarteMenuCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? ALaCarteMenuTableViewCell else {
            fatalError("The dequeued cell is not an instance of ALaCarteTableViewCell.")
        }
        
        if matchingItems.count < 1 {
            
            cell.itemLabel.text = "No items found"
            cell.priceLabel.text = ""
        } else {
            
            cell.itemLabel.text = matchingItems[indexPath.row].name
            cell.priceLabel.text = matchingItems[indexPath.row].price
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, canEditAtRowAt indexPath: IndexPath) -> Bool {
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
