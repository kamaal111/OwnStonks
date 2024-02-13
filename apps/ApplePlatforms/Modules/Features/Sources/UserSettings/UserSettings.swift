//
//  UserSettings.swift
//
//
//  Created by Kamaal M Farah on 13/12/2023.
//

import SwiftUI
import ForexKit
import Observation
import KamaalLogger
import KamaalSettings
import KamaalExtensions

/// Observable object that manages user settings.
@Observable
public final class UserSettings {
    private(set) var appColor = AppColor(
        id: UUID(uuidString: "d3256bc6-84a4-4717-a970-9d2d3a1724b4")!,
        name: NSLocalizedString("Default color", bundle: .module, comment: ""),
        color: Color("AccentColor")
    )
    private(set) var preferredCurrency: Preference.Option
    /// Whether to show money or not.
    public private(set) var showMoney: Bool

    private let showLogs = true
    private let logger = KamaalLogger(from: UserSettings.self, failOnError: true)
    private var quickStorage: UserSettingsQuickStoragable

    /// Intializer of ``UserSettings/UserSettings``.
    public convenience init() {
        self.init(quickStorage: UserSettingsQuickStorage.shared)
    }

    init(quickStorage: UserSettingsQuickStoragable) {
        self.preferredCurrency = quickStorage.preferredCurrency ?? Self.preferredCurrencies[0]
        self.showMoney = quickStorage.showMoney ?? true
        self.quickStorage = quickStorage
    }

    /// Users preferred currency selected in the ``UserSettingsScreen``.
    public var preferredForexCurrency: Currencies {
        Currencies.allCases.find(by: \.id, is: preferredCurrency.id) ?? .EUR
    }

    var configuration: SettingsConfiguration {
        SettingsConfiguration(
            feedback: feedbackConfiguration,
            color: colorConfiguration,
            features: features,
            acknowledgements: AcknowledgementsJSON.shared.content,
            preferences: preferences,
            showLogs: showLogs
        )
    }

    @MainActor
    func onPreferenceChange(_ preference: Preference) {
        switch preference.id {
        case currencyPreference.id: setPreferredCurrency(preference.selectedOption)
        default: logger.error("Failed to find preference by id")
        }
    }

    @MainActor
    func onFeaturesChange(_ feature: Feature) {
        switch feature.id {
        case showMoneyFeature.id: setShowMoneyFeature(feature.isEnabled)
        default: logger.error("Failed to find feature by id")
        }
    }

    static let currencyPreferenceID = UUID(uuidString: "bb2062c5-0227-442a-a47f-5679f3fbe36f")!

    private var features: [Feature] {
        [
            showMoneyFeature,
        ]
    }

    private var showMoneyFeature: Feature {
        .init(
            id: UUID(uuidString: "1ce3d891-0e71-4702-aa69-2195e93b1dba")!,
            label: NSLocalizedString("Show money", bundle: .module, comment: ""),
            isEnabled: showMoney
        )
    }

    private var colorConfiguration: SettingsConfiguration.ColorsConfiguration {
        .init(colors: [appColor], currentColor: appColor)
    }

    private var feedbackConfiguration: SettingsConfiguration.FeedbackConfiguration? {
        guard let feedbackToken = SecretsJSON.shared.content?.githubToken else { return nil }

        #if os(macOS)
        let deviceLabel = "macOS"
        #else
        let deviceLabel = UIDevice.current.userInterfaceIdiom == .pad ? "iPadOS" : "iOS"
        #endif
        return .init(
            token: feedbackToken,
            username: Constants.repo.username,
            repoName: Constants.repo.name,
            additionalLabels: [deviceLabel, "in app feedback"]
        )
    }

    private var preferences: [Preference] {
        [
            currencyPreference,
        ]
    }

    private var currencyPreference: Preference {
        .init(
            id: Self.currencyPreferenceID,
            label: NSLocalizedString("Preferred currency", bundle: .module, comment: ""),
            selectedOption: preferredCurrency,
            options: Self.preferredCurrencies
        )
    }

    @MainActor
    private func setShowMoneyFeature(_ showMoneyState: Bool) {
        showMoney = showMoneyState
        quickStorage.showMoney = showMoneyState
    }

    @MainActor
    private func setPreferredCurrency(_ currency: Preference.Option) {
        preferredCurrency = currency
        quickStorage.preferredCurrency = currency
    }

    private static let preferredCurrencies: [Preference.Option] = Currencies.allCases
        .filter { currency in !currency.isCryptoCurrency }
        .map { currency in Preference.Option(id: currency.id, label: currency.localized) }
}
