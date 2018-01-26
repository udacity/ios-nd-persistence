//
//  Note+Extensions.swift
//  Mooskine
//
//  Created by Kathryn Rotondo on 10/21/17.
//  Copyright © 2017 Udacity. All rights reserved.
//

import Foundation
import CoreData

extension Note {
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        creationDate = Date()
    }
}
