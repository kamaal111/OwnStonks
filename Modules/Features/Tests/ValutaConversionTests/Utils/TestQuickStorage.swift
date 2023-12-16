//
//  TestQuickStorage.swift
//
//
//  Created by Kamaal M Farah on 16/12/2023.
//

import ForexKit
import Foundation
@testable import ValutaConversion

class TestQuickStorage: ValutaConversionQuickStoragable {
    var exchangeRates: [Date: [ExchangeRates]]?

    init(exchangeRates: [Date: [ExchangeRates]]? = nil) {
        self.exchangeRates = exchangeRates
    }
}
