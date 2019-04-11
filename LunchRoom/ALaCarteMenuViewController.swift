//
//  ALaCarteMenuViewController.swift
//  ISD196LunchroomApp
//
//  Created by SCHOEPKE, SAMUEL on 1/15/19.
//  Copyright © 2019 district196.org. All rights reserved.
//

import UIKit

var selectedName = "Name"
var selectedPrice = "$0.00"

class ALaCarteMenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var matchingItems = [MenuItem]()
    
    @IBOutlet weak var emptyViewLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var searchBar: UITextField!
    @IBOutlet weak var aLaCarteMenuTableView: UITableView!
    @IBOutlet weak var deleteTextButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emptyViewLabel.isHidden = true
        
        aLaCarteMenuTableView.delegate = self
        aLaCarteMenuTableView.dataSource = self
        
        deleteTextButton.isHidden = true
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func returnToMainMenu(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func searchBarEdited(_ sender: UITextField) {
        aLaCarteMenuTableView.reloadData()
    }
    
    @IBAction func searchButtonPressed(_ sender: UIButton) {
        searchBar.resignFirstResponder()
    }
    
    @IBAction func returnButtonPressed(_ sender: UITextField) {
        searchBar.resignFirstResponder()
    }
    
    @IBAction func deleteText(_ sender: UIButton) {
        searchBar.text = ""
        aLaCarteMenuTableView.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        matchingItems = Array(aLaCarteItems.values)
        
        if let text = searchBar.text {
            if text.count > 0 {
                for x in stride(from: matchingItems.count - 1, to: -1, by: -1) {
                    
                    let itemName = matchingItems[x].name.lowercased()
                    let key = text.lowercased()
                    
                    if itemName.components(separatedBy: key).count < 2 {
                        matchingItems.remove(at: x)
                    }
                }
            }
        }
        
        if searchBar.text != "" {
            deleteTextButton.isHidden = false
        } else {
            deleteTextButton.isHidden = true
        }
        
        if matchingItems.count >= 1 {
            
            emptyViewLabel.isHidden = true
            
            return matchingItems.count
            
        } else {
            
            emptyViewLabel.isHidden = false
            
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "aLaCarteMenuCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? ALaCarteMenuTableViewCell else {
            fatalError("The dequeued cell is not an instance of ALaCarteTableViewCell.")
        }
        
        cell.itemLabel.text = matchingItems[indexPath.row].name
        cell.priceLabel.text = matchingItems[indexPath.row].price

        return cell
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        aLaCarteMenuTableView.deselectRow(at: indexPath, animated: true)
        searchBar.resignFirstResponder()
        selectedName = matchingItems[indexPath.row].name
        selectedPrice = matchingItems[indexPath.row].price
        performSegue(withIdentifier: "itemPopup", sender: self)
    }
}
