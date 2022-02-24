//
//  ChatViewController.swift
//  Yelpy
//
//  Created by Memo on 7/1/20.
//  Copyright © 2020 memo. All rights reserved.
//

/*------ Comment ------*/

import UIKit
import Parse

class ChatViewController: UIViewController {
  
  @IBOutlet weak var messageTextField: UITextField!
  @IBOutlet weak var tableView: UITableView!
  
  private var messages = [PFObject]() {
    didSet {
      tableView.reloadData()
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.dataSource = self
    tableView.delegate = self
    tableView.rowHeight = UITableView.automaticDimension
    tableView.estimatedRowHeight = 50
    
    fetchMessagesEverySecond()
  }
  
  private func fetchMessagesEverySecond() {
    Timer.scheduledTimer(withTimeInterval: 1.0,
                         repeats: true) { [weak self] timer in
      let query = PFQuery(className: "Message")
      query.includeKey("user")
      query.addDescendingOrder("createdAt")
      query.findObjectsInBackground { [weak self] messages, error in
          if let error = error {
            print("Error in fetching messages: \(error.localizedDescription)")
          } else {
            self?.messages = messages ?? []
          }
      }
    }
  }
  
  @IBAction func onSend(_ sender: Any) {
    guard let messageText = messageTextField.text, !messageText.isEmpty else {
      print("Can't send empty message")
      return
    }
    let message = PFObject(className: "Message")
    message["text"] = messageText
    message["user"] = PFUser.current()
    message.saveInBackground { isSuccess, error in
      if let error = error {
        print("Error in sending message: \(error.localizedDescription)")
      } else {
        print("Message successfully sent")
      }
    }
    messageTextField.text?.removeAll()
  }
  
  @IBAction func onLogout(_ sender: Any) {
    NotificationCenter.default.post(name: NSNotification.Name("logout"),
                                    object: nil)
  }
  
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return true
  }
}

extension ChatViewController: UITableViewDelegate, UITableViewDataSource {

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return messages.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "ChatCell", for: indexPath)
    let message = messages[indexPath.row]
    cell.textLabel?.text = message["text"] as? String
    if let user = message["user"] as? PFUser {
      cell.detailTextLabel?.text = user.username
    } else {
      cell.detailTextLabel?.text = "[Unknown User]"
    }
    return cell
  }
}



