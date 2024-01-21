//
//  TestQuickStorage.swift
//
//
//  Created by Kamaal M Farah on 16/12/2023.
//

@testable import UserSettings
import KamaalSettings

class TestQuickStorage: UserSettingsQuickStoragable {
    var preferredCurrency: Preference.Option?
    var showMoney: Bool?

    init(preferredCurrency: Preference.Option? = nil, showMoney: Bool? = nil) {
        self.preferredCurrency = preferredCurrency
        self.showMoney = showMoney
    }
}
