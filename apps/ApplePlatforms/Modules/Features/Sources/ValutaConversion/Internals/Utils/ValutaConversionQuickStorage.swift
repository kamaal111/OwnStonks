//
//  ValutaConversionQuickStorage.swift
//
//
//  Created by Kamaal M Farah on 16/12/2023.
//

import ForexKit
import Foundation
import KamaalUtils
import SharedUtils

public protocol ValutaConversionQuickStoragable: CacheContainerable { }

class ValutaConversionQuickStorage: ValutaConversionQuickStoragable {
    @UserDefaultsObject(key: makeKey("exchange_rates"), container: UserDefaultsSuite.shared)
    var exchangeRates: [Date: [ExchangeRates]]?

    private static func makeKey(_ key: String) -> String {
        "\(Constants.bundleIdentifier).\(key)"
    }
}
