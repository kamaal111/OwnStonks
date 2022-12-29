//
//  OSLocales.swift
//
//
//  Created by Kamaal M Farah on 28/12/2022.
//

import Foundation

/// Main Localization util struct.
public struct OSLocales {
    private init() { }

    /// Gets localized string.
    /// - Parameter key: the localized key.
    /// - Returns: a localized string.
    public static func getText(_ key: Keys) -> String {
        key.localized
    }
}

extension OSLocales.Keys {
    /// Localize ``OSLocales/OSLocales/Keys``.
    public var localized: String {
        localized(with: [])
    }

    /// Localize ``OSLocales/OSLocales/Keys`` with a injected variable.
    /// - Parameter variables: variable to inject in to string.
    /// - Returns: Returns a localized string.
    public func localized(with variables: [CVarArg]) -> String {
        let bundle = Bundle.module
        switch variables {
        case _ where variables.isEmpty:
            return NSLocalizedString(rawValue, bundle: bundle, comment: "")
        case _ where variables.count == 1:
            return String(format: NSLocalizedString(rawValue, bundle: bundle, comment: ""), variables[0])
        default:
            assertionFailure("Amount of variables is not supported")
            return NSLocalizedString(rawValue, bundle: bundle, comment: "")
        }
    }
}
