//
//  DBChatInProcess+CoreDataProperties.swift
//  
//
//  Created by raghav vij on 7/31/16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension DBChatInProcess {

    @NSManaged var message: String?
    @NSManaged var messageID: String?
    @NSManaged var chatWithBuddyInProcess: DBBuddy?

}
