//
//  TestTransactionsQuickStorage.swift
//
//
//  Created by Kamaal M Farah on 24/12/2023.
//

import Foundation
@testable import Transactions

class TestTransactionsQuickStorage: TransactionsQuickStoragable {
    var stonksAPIGetCache: [URL: Data]?
    var pendingCloudChanges = false
}
