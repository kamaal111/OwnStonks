//
//  AppTransactionDataSource.swift
//
//
//  Created by Kamaal M Farah on 01/01/2024.
//

import Foundation
import SharedModels

struct AppTransactionDataSource: Hashable, Identifiable {
    let id: UUID?
    let sourceType: AssetDataSources
    let ticker: String

    init(id: UUID? = nil, sourceType: AssetDataSources, ticker: String) {
        self.id = id
        self.sourceType = sourceType
        self.ticker = ticker
    }
}
