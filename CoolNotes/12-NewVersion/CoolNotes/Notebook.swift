//
//  Notebook.swift
//  CoolNotes
//
//  Created by Fernando Rodríguez Romero on 10/03/16.
//  Copyright © 2016 udacity.com. All rights reserved.
//

import Foundation
import CoreData

// MARK: - Notebook: NSManagedObject

class Notebook: NSManagedObject {
    
    // MARK: Initializer
    
    convenience init(name: String, context: NSManagedObjectContext){
        
        // An EntityDescription is an object that has access to all
        // the information you provided in the Entity part of the model
        // you need it to create an instance of this class.
        if let ent = NSEntityDescription.entity(forEntityName: "Notebook", in: context) {
            self.init(entity: ent, insertInto: context)
            self.name = name;
            self.creationDate = Date()
        } else {
            fatalError("Unable to find Entity name!")
        }
    }
}
