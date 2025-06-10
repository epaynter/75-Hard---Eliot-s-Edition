//
//  Item.swift
//  75 Hard - Eliot's Edition
//
//  Created by Eliot Paynter on 6/10/25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
