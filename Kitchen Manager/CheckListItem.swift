//
//  CheckListItem.swift
//  Kitchen Manager
//
//  Created by Liza Linto on 11/29/15.
//  Copyright © 2015 Liza Linto. All rights reserved.
//

import UIKit

class CheckListItem: NSObject {
    // A text description of this item.
    var text: String
    
    // item group title
    var section : String
    
    // A Boolean value that determines the striked state of this item.
    var striked: Bool
    
    // Returns a CheckListItem initialized with the given text and default checked value.
    init(text: String) {
        self.text = text
        self.striked = false
        self.section = "Uncategorized"
    }
    init(text: String, striked : Bool) {
        self.text = text
        self.striked = striked
        self.section = "Uncategorized"
    }
    init(text: String, striked : Bool, section : String) {
        self.text = text
        self.striked = striked
        self.section = section
    }

}
