//
//  StonkGridCellData.swift
//  OwnStonks
//
//  Created by Kamaal Farah on 06/05/2021.
//  Copyright © 2021 Kamaal Farah. All rights reserved.
//

import StonksUI
import Foundation

struct StonkGridCellData: StonkGridCellRenderable {
    let id: Int
    let content: String
    let transactionID: UUID

    internal init(id: Int, content: String, transactionID: UUID) {
        self.id = id
        self.content = content
        self.transactionID = transactionID
    }
}
