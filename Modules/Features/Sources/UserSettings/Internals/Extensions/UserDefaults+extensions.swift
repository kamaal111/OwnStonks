//
//  UserDefaults+extensions.swift
//
//
//  Created by Kamaal M Farah on 16/12/2023.
//

import Foundation
import KamaalUtils
import SharedStuff
import KamaalSettings

protocol UserSettingsQuickStoragable {
    var preferredCurrency: Preference.Option? { get set }
}

struct UserSettingsQuickStorage: UserSettingsQuickStoragable {
    @UserDefaultsObject(key: makeKey("preferred_currency"), container: UserDefaultsSuite.shared)
    var preferredCurrency: Preference.Option?

    private init() { }

    static let shared = UserSettingsQuickStorage()

    private static func makeKey(_ key: String) -> String {
        "\(Constants.bundleIdentifier).\(key)"
    }
}
