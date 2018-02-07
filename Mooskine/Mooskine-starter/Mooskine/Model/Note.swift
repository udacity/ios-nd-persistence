//
//  Note.swift
//  Mooskine
//
//  Created by Josh Svatek on 2017-05-31.
//  Copyright © 2017 Udacity. All rights reserved.
//

import Foundation

class Note {
    /// The date the note was created
    let creationDate: Date

    /// The note's text
    var text: String

    init(text: String = "New note") {
        self.text = text
        creationDate = Date()
    }
}
