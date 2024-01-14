//
//  TestTransactionsQuickStorage.swift
//
//
//  Created by Kamaal M Farah on 24/12/2023.
//

import ForexKit
import StonksKit
import Foundation
@testable import Transactions
import ValutaConversion

class TestTransactionsQuickStorage: TransactionsQuickStoragable, ValutaConversionQuickStoragable {
    var closesCache: [Date: [String: StonksTickersClosesResponse]]?
    var exchangeRates: [Date: [ExchangeRates]]?
    var infoCache: [Date: [String: StonksTickersInfoResponse]]?
    var pendingCloudChanges = false
}
