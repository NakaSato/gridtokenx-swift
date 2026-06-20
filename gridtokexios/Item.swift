//
//  Item.swift
//  gridtokexios
//
//  Created by Chanthawat Kiriyadee on 20/6/2569 BE.
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
