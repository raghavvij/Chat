//
//  ChatVC.swift
//  ChatMessenger
//
//  Created by raghav vij on 7/18/16.
//  Copyright © 2016 raghav vij. All rights reserved.
//

import UIKit
import CoreData
import XMPPFramework
class ChatVC: UIViewController,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,SMMessageDelegate {

    @IBOutlet weak var textFieldBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var chatTextField: UITextField!
    @IBOutlet weak var chatTableView: UITableView!
    var buddyIndex = 0
    var newBuddyAdded:Bool?
    var newMessageAdded:Bool? = false
     let appDel = (UIApplication.sharedApplication().delegate as? AppDelegate)
    let context = (UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext
    var buddy:DBBuddy?
    lazy var messages:[[String:String?]]? = {
        return [[String:String?]]()
    }()
    var chatWithUser:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        chatTableView.delegate = self
        chatTableView.dataSource = self
        self.chatTextField.becomeFirstResponder()
        appDel?.messageDelegate = self
        self.chatTableView.estimatedRowHeight = 67.0
        self.chatTableView.rowHeight = UITableViewAutomaticDimension
        self.fetchBuddy(chatWithUser)
        let chatNib = UINib(nibName: "BuddyChatCell", bundle: nil)
        self.chatTableView.registerNib(chatNib, forCellReuseIdentifier: "BuddyChatCell")
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func closeChat(sender: AnyObject) {
        do {
            if newMessageAdded == true {
            try context!.save()
            print("saved \(buddy)")
            if newBuddyAdded == true {
                buddyIndex += 1
                NSUserDefaults.standardUserDefaults().setInteger(buddyIndex, forKey: "buddyIndex")
            }
            }
        }
        catch let error as NSError {
            print("couldn't save \(error) \(error.userInfo)")
        }
       self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func sendMessage(sender: AnyObject) {
        //send message through XMPP
        let message = chatTextField.text
        if message?.characters.count > 0 {
            let body = DDXMLElement.elementWithName("body") as! DDXMLElement
            body.setStringValue(message)
            let xmlMessage = DDXMLElement(name: "message")
            xmlMessage.addAttributeWithName("type", stringValue: "chat")
            xmlMessage.addAttributeWithName("to", stringValue: chatWithUser)
            xmlMessage.addChild(body)
            print("\(xmlMessage)")
            appDel!.xmpp?.sendElement(xmlMessage)
            let dict = ["msg":message,"sender":"you"]
                messages?.append(dict)
                self.chatTextField.text = ""
                self.chatTableView.reloadData()
                self.saveMessage(dict)
        }
    }
    
    func newMessageReceived(messageContent: [String : String]?) {
        if let message = messageContent {
        let dict = ["sender" : message["sender"],"msg":message["msg"]]
        print("\(message)")
        messages?.append(dict)
        self.chatTableView.reloadData()
        self.saveMessage(dict)
        }
    }
    
    func fetchBuddy(name:String?)  {
        let fetchRequest = NSFetchRequest(entityName: "DBBuddy")
        let sortDesc = NSSortDescriptor(key: "timestamp", ascending: false)
        let predicate = NSPredicate(format: "firstName = %@", name!)
        fetchRequest.predicate = predicate
        do {
            let results = try context?.executeFetchRequest(fetchRequest)
            if results?.count == 0 {
                self.newBuddyAdded = true
                self.saveBuddy(chatWithUser)
            }
            else {
                var messageResults = results as! [NSManagedObject]
                newBuddyAdded = false
                buddy = (messageResults[0] as! DBBuddy)
                let chatArray = (messageResults[0] as! DBBuddy).buddyChat
                chatArray?.sortedArrayUsingDescriptors([sortDesc])
                for chatMessageObject in chatArray! {
                    let chatHistory = chatMessageObject as! DBChatHistory
                    let dict = ["sender" : chatHistory.sender,"msg":chatHistory.message,"timeStamp": "\(chatHistory.timestamp)"]
                    messages?.append(dict)
                }
                let df = NSDateFormatter()
                df.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
//                messages?.sortInPlace({(df.dateFromString(String(($0)["timeStamp"])))?.timeIntervalSince1970  < (df.dateFromString(String(($1)["timeStamp"])))?.timeIntervalSince1970 })
                 messages?.sortInPlace({$0["timeStamp"]! < $1["timeStamp"]!})
                self.chatTableView.reloadData()
            }
        }
        catch let error as NSError {
            print("couldn't save \(error) \(error.userInfo)")
        }
    }
    
    
    
    func saveBuddy(name:String?) {
        buddy = NSEntityDescription.insertNewObjectForEntityForName("DBBuddy", inManagedObjectContext: context!) as? DBBuddy
        buddy!.firstName = name
        if (NSUserDefaults.standardUserDefaults().objectForKey("buddyIndex") != nil) {
            buddy!.personId = String(format: "%d",(NSUserDefaults.standardUserDefaults().objectForKey("buddyIndex")?.intValue)!)
        }else {
        buddy!.personId = String(format:"%d",buddyIndex)
        }
    }
    
    func saveMessage(messageDict:[String:String?]) {
        newMessageAdded = true
        let message = NSEntityDescription.insertNewObjectForEntityForName("DBChatHistory", inManagedObjectContext: context!) as! DBChatHistory
        message.message = messageDict["msg"]!
        message.sender = messageDict["sender"]!
        message.timestamp = NSDate()
        buddy?.mutableSetValueForKey("buddyChat").addObject(message)
    }
    
    // MARK: - TableView Delegates
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if messages?.count > 0 {
            return (messages?.count)!
        }
        return 0
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let identifier = "BuddyChatCell"
        let cell:BuddyChatCell? = (tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as? BuddyChatCell)
        
        if let _ = messages,messageValue = messages?[indexPath.row]["msg"],senderName = messages?[indexPath.row]["sender"]  {
            cell?.configureCell(messageValue, sender:senderName)
        }
        return cell!
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        textFieldBottomConstraint.constant = 10.0
        UIView.animateWithDuration(0.25,
                                   animations: {() -> Void in
                                    self.view.layoutIfNeeded()
        })
        self.view.layoutIfNeeded()
    }

}
