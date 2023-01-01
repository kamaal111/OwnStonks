//
//  Currencies.swift
//  
//
//  Created by Kamaal M Farah on 01/01/2023.
//

import Foundation

public enum Currencies: String, CaseIterable, Codable {
    case EUR
    case USD

    public var symbol: String {
        switch self {
        case .EUR:
            return "€"
        case .USD:
            return "$"
        }
    }
}
