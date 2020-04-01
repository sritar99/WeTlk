//
//  ChatViewController.swift
//  Flash Chat iOS13
//
//  Created by Angela Yu on 21/10/2019.
//  Copyright © 2019 Angela Yu. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase
class ChatViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextfield: UITextField!
    
    let db = Firestore.firestore()
    
    var messages:[Message] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        tableView.delegate = self
        tableView.dataSource = self
        title = "🤫WeTlk👻"
        navigationItem.hidesBackButton = true
        tableView.register(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "ReusableCell")
        loadMessages()

    }
    
    func loadMessages() {
        
        db.collection("SecretChat")
            .order(by: "date")
            .addSnapshotListener { (querySnapshot, error) in
            
            self.messages = []
            
            if let e = error {
                print("There was an issue retrieving data from Firestore. \(e)")
            } else {
                if let snapshotDocuments = querySnapshot?.documents {
                    for doc in snapshotDocuments {
                        let data = doc.data()
                        if let messageSender = data["Sender"] as? String, let messageBody = data["Body"] as? String {
                            let newMessage = Message(sender: messageSender, body: messageBody)
                            self.messages.append(newMessage)
                            
                            DispatchQueue.main.async {
                                   self.tableView.reloadData()
                                let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
                                self.tableView.scrollToRow(at: indexPath, at: .top, animated: false)
                            }
                        }
                    }
                }
            }
        }
    }

    
    
    
    
    
    
    
    @IBAction func sendPressed(_ sender: UIButton) {
        if let MessageBody = messageTextfield.text, let Sender = Auth.auth().currentUser?.email{
            
            if (MessageBody.count > 0){
                db.collection("SecretChat")
                    .addDocument(data: ["Sender": Sender,"Body": MessageBody,
                        "date": Date().timeIntervalSince1970
                        ]){ (error) in
                        if let e = error{
                            print("Issue in adding data to Firebase")
                        }else{
                            print("Successfully saved the data")
                                DispatchQueue.main.async {
                                self.messageTextfield.text = ""
                                }
                        }
                }

            }
                        
            
        }
    }
    
    @IBAction func LogOutKeyPress(_ sender: UIBarButtonItem) {
        do {
            try Auth.auth().signOut()
            navigationController?.popToRootViewController(animated: true)
        } catch let signOutError as NSError {
          print ("Error signing out: %@", signOutError)
        }
          
    }
    
}


extension ChatViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReusableCell", for: indexPath) as! MessageCell
        cell.label.text = message.body
        
        //This is a message from the current user.
        if message.sender == Auth.auth().currentUser?.email {
            cell.leftImageView.isHidden = true
            cell.rightImageView.isHidden = false
            cell.messageBubble.backgroundColor = UIColor(named:"BrandLightPurple")
            cell.label.textColor = UIColor(named: "BrandPurple")
        }
        //This is a message from another sender.
        else {
            cell.leftImageView.isHidden = false
            cell.rightImageView.isHidden = true
            cell.messageBubble.backgroundColor = UIColor(named: "BrandLightBlue")
            cell.label.textColor = UIColor(named: "BrandBlue")
        }
        
      
      
        return cell
    }
}
//when i used this function i wrote in the viewdidload as tableview.delegate=self
//extension ChatViewController: UITableViewDelegate{
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        print(indexPath.row)
//    }
//}
