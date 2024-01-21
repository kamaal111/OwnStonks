//
//  UserSettingsQuickStorage.swift
//
//
//  Created by Kamaal M Farah on 16/12/2023.
//

import Foundation
import KamaalUtils
import SharedUtils
import KamaalSettings

protocol UserSettingsQuickStoragable {
    var preferredCurrency: Preference.Option? { get set }
    var showMoney: Bool? { get set }
}

class UserSettingsQuickStorage: UserSettingsQuickStoragable {
    @UserDefaultsObject(key: makeKey("preferred_currency"), container: UserDefaultsSuite.shared)
    var preferredCurrency: Preference.Option?

    @UserDefaultsValue(key: makeKey("show_money"), container: UserDefaultsSuite.shared)
    var showMoney: Bool?

    private init() { }

    static let shared = UserSettingsQuickStorage()

    private static func makeKey(_ key: String) -> String {
        "\(Constants.bundleIdentifier).\(key)"
    }
}
