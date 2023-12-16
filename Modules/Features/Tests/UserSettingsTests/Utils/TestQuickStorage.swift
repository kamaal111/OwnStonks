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

    init(preferredCurrency: Preference.Option?) {
        self.preferredCurrency = preferredCurrency
    }
}
