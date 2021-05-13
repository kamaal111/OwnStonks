//
//  UserDefaults.swift
//  OwnStonks
//
//  Created by Kamaal M Farah on 08/05/2021.
//  Copyright © 2021 Kamaal Farah. All rights reserved.
//

import Foundation

extension UserDefaults {
    @UserDefault(key: .currencyLocaleIdentifier)
    static var currencyLocaleIdentifier: String?
}

@propertyWrapper
struct UserDefault<Value> {
    let key: Keys

    init(key: Keys) {
        self.key = key
    }

    enum Keys: String {
        case currencyLocaleIdentifier
    }

    var wrappedValue: Value? {
        get {
            let userDefaults: UserDefaults = .standard
            let valueToReturn = userDefaults.object(forKey: constructKey(key.rawValue)) as? Value
            return valueToReturn
        }
        set {
            let userDefaults: UserDefaults = .standard
            userDefaults.set(newValue, forKey: constructKey(key.rawValue))
        }
    }

    var projectedValue: UserDefault {
        self
    }

    func removeValue() {
        let userDefaults: UserDefaults = .standard
        userDefaults.removeObject(forKey: constructKey(key.rawValue))
    }

    private func constructKey(_ key: String) -> String {
        "\(Constants.appBundleIdentifier).UserDefaults.\(key)"
    }
}
