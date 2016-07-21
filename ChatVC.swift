//
//  ChatVC.swift
//  ChatMessenger
//
//  Created by raghav vij on 7/18/16.
//  Copyright © 2016 raghav vij. All rights reserved.
//

import UIKit
import XMPPFramework
class ChatVC: UIViewController,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,SMMessageDelegate {

    @IBOutlet weak var textFieldBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var chatTextField: UITextField!
    @IBOutlet weak var chatTableView: UITableView!
     let appDel = (UIApplication.sharedApplication().delegate as? AppDelegate)
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
        let chatNib = UINib(nibName: "BuddyChatCell", bundle: nil)
        self.chatTableView.registerNib(chatNib, forCellReuseIdentifier: "BuddyChatCell")
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func closeChat(sender: AnyObject) {
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
        }
    }
    
    func newMessageReceived(messageContent: [String : String]?) {
        if let message = messageContent {
        let dict = ["sender" : message["sender"],"msg":message["msg"]]
        print("\(message)")
        messages?.append(dict)
        self.chatTableView.reloadData()
        }
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
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
