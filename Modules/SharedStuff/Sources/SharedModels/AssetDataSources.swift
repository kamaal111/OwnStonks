//
//  AssetDataSources.swift
//
//
//  Created by Kamaal M Farah on 30/12/2023.
//

import Foundation

public enum AssetDataSources: String, CaseIterable, LocalizedItem {
    case stocks

    public var localized: String {
        switch self {
        case .stocks: NSLocalizedString("Stocks", bundle: .module, comment: "")
        }
    }
}
