//
//  UserSettingsSpec.swift
//
//
//  Created by Kamaal M Farah on 16/12/2023.
//

import Quick
import Nimble
import ForexKit
import Foundation
import KamaalSettings
import KamaalExtensions
@testable import UserSettings

final class UserSettingsSpec: AsyncSpec {
    override class func spec() {
        describe("Setting preferred currency") {
            it("should have Euro as default currency") {
                // Given
                let storage = TestQuickStorage(preferredCurrency: nil)

                // When
                let userSettings = UserSettings(quickStorage: storage)

                // Then
                expect(userSettings.preferredCurrency.label) == Currencies.EUR.localized
                expect(userSettings.preferredCurrency.id) == Currencies.EUR.id
                expect(storage.preferredCurrency).to(beNil())
            }

            context("Set preferred currency with given currency") {
                for currency in Currencies.allCases.filter({ currency in !currency.isCryptoCurrency }) {
                    it("should set preferred currency to \(currency.localized)") {
                        // Given
                        let storage = TestQuickStorage(preferredCurrency: nil)
                        let userSettings = UserSettings(quickStorage: storage)

                        // When
                        await setCurrencyPreference(on: userSettings, with: currency)

                        // Then
                        expect(userSettings.preferredCurrency.label) == currency.localized
                        expect(userSettings.preferredCurrency.id) == currency.id
                        expect(storage.preferredCurrency) == userSettings.preferredCurrency
                    }
                }
            }
        }
    }
}

private func setCurrencyPreference(on settings: UserSettings, with currency: Currencies) async {
    let currencyPreference = settings.configuration.preferences.find(by: \.id, is: UserSettings.currencyPreferenceID)!
    let newPreference = Preference(
        id: currencyPreference.id,
        label: currencyPreference.label,
        selectedOption: currencyPreference.options.find(by: \.id, is: currency.id)!,
        options: currencyPreference.options
    )
    await settings.onPreferenceChange(newPreference)
}
