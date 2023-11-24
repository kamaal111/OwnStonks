//
//  Item.swift
//  OwnStonks
//
//  Created by Kamaal M Farah on 24/11/2023.
//

import SwiftData
import Foundation

@Model
final class Item {
    var timestamp: Date

    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
