//
//  UserData.swift
//  OwnStonks
//
//  Created by Kamaal M Farah on 03/01/2023.
//

import Models
import SwiftUI
import Logster
import OSLocales
import SettingsUI
import ShrimpExtensions

private let logger = Logster(from: UserData.self)

final class UserData: ObservableObject {
    @Published private(set) var preferedCurrency: Currencies {
        didSet { preferedCurrencyDidSet() }
    }
    @Published private var showLogs = true
    @Published private var acknowledgements: Acknowledgements?

    init() {
        self.preferedCurrency = UserDefaults.preferedCurrency ?? .EUR
    }

    var settingsConfiguration: SettingsConfiguration {
        .init(acknowledgements: acknowledgements, preferences: preferences, showLogs: showLogs)
    }

    func loadAcknowledgements() async {
        guard acknowledgements == nil else { return }

        guard let acknowledgements = JSONUnpacker<Acknowledgements>(filename: "Acknowledgements").content else {
            logger.error("Failed to find acknowledgements")
            assertionFailure("Failed to find acknowledgements")
            return
        }

        await setAcknowledgements(acknowledgements)
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
            #warning("Should refetch exchange rates")
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

    @MainActor
    private func setAcknowledgements(_ acknowledgements: Acknowledgements) {
        logger.info("acknowledgements loaded")
        withAnimation { self.acknowledgements = acknowledgements }
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
