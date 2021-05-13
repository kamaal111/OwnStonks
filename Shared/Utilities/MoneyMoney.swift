//
//  MoneyMoney.swift
//  OwnStonks
//
//  Created by Kamaal M Farah on 08/05/2021.
//  Copyright © 2021 Kamaal Farah. All rights reserved.
//

import Foundation

struct MoneyMoney {
    private init() { }

    enum Currencies: String, CaseIterable {
        case USD
        case EUR
        case JPY
        case GBP
        case AUD
        case CAD
        case CHF
        case CNY
        case HKD
        case NZD
        case SEK
        case KRW
        case SGD
        case NOK
        case MXN
    }

    static func getLocaleForCurrencyCode(code: Currencies) -> Locale? {
        var localeWithSmallestSymbol: Locale?
        for localeID in NSLocale.availableLocaleIdentifiers {
            guard let locale = findMatchingLocale(localeID: localeID, currencyCode: code),
                  let symbol = locale.currencySymbol else { continue }
            if symbol.count == 1 {
                return locale
            }
            if let localeWithSmallestSymbolSymbol = localeWithSmallestSymbol?.currencySymbol {
                if symbol.count < localeWithSmallestSymbolSymbol.count {
                    localeWithSmallestSymbol = locale
                }
            } else {
                localeWithSmallestSymbol = locale
            }
        }
        return localeWithSmallestSymbol
    }

    static func findMatchingLocale(localeID: String, currencyCode: Currencies) -> Locale? {
        let locale = Locale(identifier: localeID)
        guard let code = locale.currencyCode, code == currencyCode.rawValue else { return nil }
        return locale
    }
}
