//
//  DBBuddy+CoreDataProperties.swift
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

extension DBBuddy {

    @NSManaged var firstName: String?
    @NSManaged var lastName: String?
    @NSManaged var personId: String?
    @NSManaged var buddyChat: NSSet?
    @NSManaged var buddyChatInProcess: NSMutableSet?

}
