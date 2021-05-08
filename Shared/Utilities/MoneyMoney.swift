//
//  MoneyMoney.swift
//  OwnStonks
//
//  Created by Kamaal M Farah on 08/05/2021.
//  Copyright © 2021 Kamaal Farah. All rights reserved.
//

import Foundation

struct MoneyMoney {
    private static let defaultCurrencySymbol = "€"

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

    static func getSymbolFromUserDefaults() -> String {
        if let userDefaultsCurrencyLocale = UserDefaultValues.currencyLocaleIdentifier {
            return Locale(identifier: userDefaultsCurrencyLocale).currencySymbol ?? defaultCurrencySymbol
        }
        let deviceCurrencyCode = NSLocale.current.currencyCode ?? ""
        let currency = MoneyMoney.Currencies(rawValue: deviceCurrencyCode) ?? .EUR
        guard let foundLocale = MoneyMoney.getLocaleForCurrencyCode(code: currency) else {
            #if DEBUG
            fatalError("Did not find locale")
            #else
            return defaultCurrencySymbol
            #endif
        }
        UserDefaultValues.currencyLocaleIdentifier = foundLocale.identifier
        return foundLocale.currencySymbol ?? defaultCurrencySymbol
    }
}
