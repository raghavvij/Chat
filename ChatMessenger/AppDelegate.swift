//
//  AppDelegate.swift
//  ChatMessenger
//
//  Created by raghav vij on 7/18/16.
//  Copyright © 2016 raghav vij. All rights reserved.
//

import UIKit
import XMPPFramework
@objc protocol SMChatDelegate:class {
    func newBuddyOnline(buddyName:String?)
    func buddyWentOffline(buddyName:String?)
    optional
    func didDisconnect()
}
protocol SMMessageDelegate:class {
    func newMessageReceived(messageContent:[String:String]?)
}
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, XMPPStreamDelegate {

    var window: UIWindow?
    var xmpp:XMPPStream?
    var password:String?
    var isOpen:Bool?
    weak var chatDelegate:SMChatDelegate?
    weak var messageDelegate:SMMessageDelegate?
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }
    
    func setupStream() {
        xmpp = XMPPStream()
        xmpp?.addDelegate(self, delegateQueue: dispatch_get_main_queue())
    }
    
    func goOnline() {
        let presence:XMPPPresence = XMPPPresence()
        self.xmpp?.sendElement(presence)
    }
    
    func goOffline() {
        let presence:XMPPPresence = XMPPPresence(type: "unavailable")
        self.xmpp?.sendElement(presence)
    }
    
    func connect() -> Bool {
        self.setupStream()
        let id:String?
        let myPassword:String?
        if let myID = NSUserDefaults.standardUserDefaults().objectForKey("userID") as? String,pass = NSUserDefaults.standardUserDefaults().objectForKey("userPassword") as? String {
         id = myID
         myPassword = pass
        if !(xmpp?.isDisconnected())! {
            return true
        }
        if id == nil && myPassword == nil {
            return false
        }
        
        xmpp?.myJID = XMPPJID.jidWithString(id)
        password = myPassword
        do {
            try xmpp!.connectWithTimeout(XMPPStreamTimeoutNone)
        } catch {
            print("error connecting")
            return false
        }
            return true
        }
        return false
    }
    
    func disconnect() {
        self.goOffline()
        xmpp?.disconnect()
    }
    
    //MARK: - XMPP Stream Delegates
    
    func xmppStreamDidConnect(sender: XMPPStream!) {
        // connection to the server successful
        isOpen = true
        do {
        try self.xmpp?.authenticateWithPassword(password!)
        }
        catch {
            print("error in authenticating password")
        }
    }
    
    func xmppStreamDidAuthenticate(sender: XMPPStream!) {
        // authentication successful
        self.goOnline()
    }
    
    func xmppStream(sender: XMPPStream!, didReceiveMessage message: XMPPMessage!) {
        // message received
        let msg:String? = message.body()
        let from:String? = String(message.from())
        if let newMsg = msg, sender = from {
        let m = ["msg":newMsg,"sender":sender] as [String:String]?
        messageDelegate?.newMessageReceived(m)
        }
        
    }
    
    func xmppStream(sender: XMPPStream!, didReceivePresence presence: XMPPPresence!) {
        // a buddy went offline/online
        let presenceType = presence.type()
        let myUsername = sender.myJID.user
        let presenceFromUser = presence.from().user
        if !(presenceFromUser == myUsername) {
            if presenceType == "available" {
                chatDelegate?.newBuddyOnline(String(format: "%@@%@", presenceFromUser,"raghavs-macbook-pro.local"))
            }else if presenceType == "unavailable" {
                chatDelegate?.buddyWentOffline(String(format: "%@@%@", presenceFromUser,"raghavs-macbook-pro.local"))
            }
        }
    }
    

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        self.disconnect()
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        self.connect()
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}
