//
//  UserDefaultObject.swift
//  
//
//  Created by Kamaal M Farah on 01/01/2023.
//

import Foundation

extension UserDefaults {
    @UserDefaultObject(key: .exchangeRates)
    public static var exchangeRates: [Date: ExchangeRates]?
}

@propertyWrapper
public struct UserDefaultObject<Value: Codable> {
    let key: Keys
    let container: UserDefaults?

    init(key: Keys, container: UserDefaults? = .standard) {
        self.key = key
        self.container = container
    }

    enum Keys: String {
        case exchangeRates
    }

    public var wrappedValue: Value? {
        get {
            guard let container, let data = container.object(forKey: constructedKey) as? Data else { return nil }

            return try? JSONDecoder().decode(Value.self, from: data)
        }
        set {
            guard let container, let data = try? JSONEncoder().encode(newValue) else { return }

            container.set(data, forKey: constructedKey)
        }
    }

    public var projectedValue: UserDefaultObject { self }

    func removeValue() {
        container?.removeObject(forKey: constructedKey)
    }

    private var constructedKey: String {
        "io.kamaal.OwnStonks.UserDefaults.\(key.rawValue)"
    }
}
