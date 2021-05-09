//
//  StonkGridCellRenderable.swift
//  
//
//  Created by Kamaal M Farah on 06/05/2021.
//

import Foundation

public protocol StonkGridCellRenderable: Hashable, Identifiable {
    var content: String { get }
    var id: Int { get }
    var transactionID: UUID { get }
}

extension StonkGridCellRenderable {
    var renderID: String {
        "\(content)-\(id)"
    }
}
