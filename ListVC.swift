//
//  ListVC.swift
//  ChatMessenger
//
//  Created by raghav vij on 7/18/16.
//  Copyright © 2016 raghav vij. All rights reserved.
//

import UIKit
import CoreData
class ListVC: UIViewController,UITableViewDelegate,UITableViewDataSource,SMChatDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    let appDel = (UIApplication.sharedApplication().delegate as? AppDelegate)
    let context = (UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext
    var buddyIndex  = 0
    lazy var onlineBuddies:[AnyObject]?  = {
        return [AnyObject]()
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
         let buddyNib = UINib(nibName: "ChatListCell", bundle: nil)
        tableView.registerNib(buddyNib, forCellReuseIdentifier: "ChatListCell")
        tableView.delegate = self
        tableView.dataSource = self
        appDel?.chatDelegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        let login = NSUserDefaults.standardUserDefaults().objectForKey("userID")
        if let loginID = login as? String {
            print("\(loginID)")
            appDel?.connect()
        }else{
            showLogin()
        }
    }
    
    func newBuddyOnline(buddyName: String?) {
        if ((onlineBuddies as! [String]).indexOf(buddyName!) == nil) {
        onlineBuddies?.append(buddyName!)
        self.tableView.reloadData()
        }
    }
    
    func buddyWentOffline(buddyName: String?) {
        for buddy in self.onlineBuddies! {
            if (buddy as? String) == buddyName {
                self.onlineBuddies!.removeAtIndex(buddy.indexOfAccessibilityElement(self.onlineBuddies!))
            }
        }
       self.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func showLogin() {
        //show Login View
        let loginVC = self.storyboard?.instantiateViewControllerWithIdentifier("loginVC")
        self.presentViewController(loginVC!, animated: true, completion: nil)
    }
    
    // MARK: TableView Delegates
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:ChatListCell? = tableView.dequeueReusableCellWithIdentifier("ChatListCell", forIndexPath: indexPath) as? ChatListCell
        if let buddyName = onlineBuddies?[indexPath.row] as? String {
            cell?.configureCell(buddyName)
        }
        return cell!
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let buddyCount = (onlineBuddies?.count) {
            return buddyCount
        }else {
            return 0
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //start a chat
        let chatVC = self.storyboard?.instantiateViewControllerWithIdentifier("ChatVC") as! ChatVC
        chatVC.chatWithUser = onlineBuddies![indexPath.row] as? String
        self.presentViewController(chatVC, animated: true, completion: nil)
    }
}
