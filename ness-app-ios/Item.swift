//
//  Item.swift
//  ness-app-ios
//
//  Created by Jose Erney Ospina on 15/12/25.
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
