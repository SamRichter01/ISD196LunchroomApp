//
//  CommentPopupViewController.swift
//  ISD196LunchroomApp
//
//  Created by Sam on 3/4/19.
//  Copyright © 2019 district196.org. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore

struct feedback {
    
    var commentDate = ""
    var rating = ""
    var text = ""
    var studentName = ""
}

class CommentPopupViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var itemView: UIView!
    @IBOutlet weak var commentTableView: UITableView!
    
    var comments = [feedback]()
    var line = ""
    var avgRating = 0
    var ratingCount = 0
    var month = ""
    var day = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        commentTableView.delegate = self
        commentTableView.dataSource = self
        
        itemView.layer.cornerRadius = 15
        itemView.layer.masksToBounds = false
        itemView.layer.shadowRadius = 10
        itemView.layer.shadowOpacity = 0.1
        
        
        
        titleLabel.text = "Feedback for \(line)"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        OrderDataViewController.downloadFeedbackData(forMonth: month, forDay: day, forLine: line)
        self.comments = loadedComments
        print(loadedComments.count)
        commentTableView.reloadData()
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "commentTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? CommentTableViewCell else {
            fatalError("The dequeued cell is not an instance of CommentTableViewCell.")
        }
        
        switch Int(comments[indexPath.row].rating)! {
            
        case -2:
            cell.ratingLabel.text = "Bad"
            
        case -1:
            cell.ratingLabel.text = "Poor"
            
        case 0:
            cell.ratingLabel.text = "No Opinion"
            
        case 1:
            cell.ratingLabel.text = "Good"
            
        case 2:
            cell.ratingLabel.text = "Great"
            
        default:
            cell.ratingLabel.text = "No Opinion"
        }
        
        cell.commentTextLabel.text = comments[indexPath.row].text
        cell.dateLabel.text = comments[indexPath.row].commentDate
        cell.studentNameLabel.text = comments[indexPath.row].studentName
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        commentTableView.deselectRow(at: indexPath, animated: true)
    }
}

