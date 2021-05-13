//
//  UserData.swift
//  OwnStonks
//
//  Created by Kamaal M Farah on 08/05/2021.
//  Copyright © 2021 Kamaal Farah. All rights reserved.
//

import Combine
import Foundation

final class UserData: ObservableObject {

    @Published private(set) var locale: Locale

    init() {
        if let userDefaultsCurrencyLocale = UserDefaults.currencyLocaleIdentifier {
            let locale = Locale(identifier: userDefaultsCurrencyLocale)
            self.locale = locale
        } else {
            let deviceCurrencyCode = NSLocale.current.currencyCode ?? ""
            let currency = MoneyMoney.Currencies(rawValue: deviceCurrencyCode) ?? .EUR
            if let foundLocale = MoneyMoney.getLocaleForCurrencyCode(code: currency) {
                UserDefaults.currencyLocaleIdentifier = foundLocale.identifier
                self.locale = foundLocale
            } else {
                #if DEBUG
                fatalError("Could not find locale")
                #else
                self.locale = .current
                #endif
            }
        }
    }

    var currency: String {
        locale.currencySymbol ?? "€"
    }

    var currencyFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = locale
        return formatter
    }

}
