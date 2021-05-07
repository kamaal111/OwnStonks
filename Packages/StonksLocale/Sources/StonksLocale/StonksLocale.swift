//
//  StonksLocale.swift
//  
//
//  Created by Kamaal M Farah on 07/05/2021.
//

import SwiftUI

public struct StonksLocale {
    private init() { }

    static func getLocalizableString(of key: Keys, with variables: CVarArg...) -> String {
        let bundle = Bundle.module
        let keyRawValue = key.rawValue
        guard variables.isEmpty else { fatalError("Amount of variables are not supported") }
        return NSLocalizedString(keyRawValue, bundle: bundle, comment: "")
    }
}

extension Text {
    public init(localized: StonksLocale.Keys) {
        self.init(StonksLocale.getLocalizableString(of: localized))
    }
}
