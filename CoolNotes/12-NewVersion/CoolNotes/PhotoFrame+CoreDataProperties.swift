//
//  PhotoFrame+CoreDataProperties.swift
//  CoolNotes
//
//  Created by Fernando Rodríguez Romero on 05/04/16.
//  Copyright © 2016 udacity.com. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension PhotoFrame {

    @NSManaged var imageData: NSData?
    @NSManaged var note: Note?

}
