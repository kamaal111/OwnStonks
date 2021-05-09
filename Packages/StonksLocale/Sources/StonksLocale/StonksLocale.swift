//
//  StonksLocale.swift
//  
//
//  Created by Kamaal M Farah on 07/05/2021.
//

import SwiftUI

/// StonksLocale contains keys to localize the app
public struct StonksLocale {
    private init() { }

    static func getLocalizableString(of key: Keys, with variables: [CVarArg] = []) -> String {
        let bundle = Bundle.module
        let keyRawValue = key.rawValue
        if variables.isEmpty {
            return NSLocalizedString(keyRawValue, bundle: bundle, comment: "")
        } else if variables.count == 1 {
            return String(format: NSLocalizedString(keyRawValue, bundle: bundle, comment: ""), variables[0])
        }
        #if DEBUG
        fatalError("Amount of variables are not supported")
        #else
        return NSLocalizedString(keyRawValue, bundle: bundle, comment: "")
        #endif
    }
}

extension StonksLocale.Keys {
    /// Returns a localized string
    public var localized: String {
        localized(with: [])
    }

    /// Returns a localized string with the variables provided
    /// - Parameter variables: These variables are injected in to the localized string
    /// - Returns: A localized string
    public func localized(with variables: CVarArg...) -> String {
        StonksLocale.getLocalizableString(of: self, with: variables)
    }
}

extension Text {
    /// An alternative init to use Text with `StonksLocale Keys`
    /// - Parameter localized: An localized key to get a localized `Text` view
    public init(localized: StonksLocale.Keys) {
        self.init(StonksLocale.getLocalizableString(of: localized))
    }
}
