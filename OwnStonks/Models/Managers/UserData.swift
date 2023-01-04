//
//  UserData.swift
//  OwnStonks
//
//  Created by Kamaal M Farah on 03/01/2023.
//

import Models
import Logster
import OSLocales
import SettingsUI
import Foundation
import ShrimpExtensions

private let logger = Logster(from: UserData.self)

final class UserData: ObservableObject {
    @Published private(set) var preferedCurrency: Currencies {
        didSet { preferedCurrencyDidSet() }
    }

    init() {
        self.preferedCurrency = UserDefaults.preferedCurrency ?? .EUR
    }

    var settingsConfiguration: SettingsConfiguration {
        .init(preferences: preferences)
    }

    @MainActor
    func handlePreferenceChange(_ preference: Preference) {
        switch preference.id {
        case currencyPreference.id:
            guard let currency = Currencies.allCases.find(by: \.id, is: preference.selectedOption.id) else {
                logger.error("Failed to find currency by ID")
                assertionFailure("Failed to find currency by ID")
                return
            }
            preferedCurrency = currency
        default:
            logger.error("Failed to find preference by ID")
            assertionFailure("Failed to find preference by ID")
        }
    }

    private var currencyPreference: Preference {
        .init(
            id: UUID(uuidString: "317632e0-a084-4dcb-a7f1-14df38a82f94")!,
            label: OSLocales.getText(.CURRENCY),
            selectedOption: preferedCurrency.preferenceOption,
            options: Self.currencyPreferenceOptions)
    }

    private var preferences: [Preference] {
        [
            currencyPreference
        ]
    }

    private func preferedCurrencyDidSet() {
        UserDefaults.preferedCurrency = preferedCurrency
    }

    private static let currencyPreferenceOptions: [Preference.Option] = Currencies.allCases.map(\.preferenceOption)
}

extension Currencies {
    var preferenceOption: Preference.Option {
        .init(id: id, label: rawValue)
    }
}
