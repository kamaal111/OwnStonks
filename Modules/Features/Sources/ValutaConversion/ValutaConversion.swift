//
//  ValutaConversion.swift
//
//
//  Created by Kamaal M Farah on 16/12/2023.
//

import ForexKit
import Foundation
import Observation

/// Observable object that manages user valuta exchange rates.
@Observable
public final class ValutaConversion {
    private let forexKit: ForexKit
    private let quickStorage: ValutaConversionQuickStoragable

    /// Initializer of ``ValutaConversion/ValutaConversion``.
    public convenience init() {
        let quickStorage = ValutaConversionQuickStorage()
        let forexKit = Self.makeForexKit(withStorage: quickStorage)
        self.init(quickStorage: quickStorage, forexKit: forexKit)
    }

    init(quickStorage: ValutaConversionQuickStoragable, forexKit: ForexKit) {
        self.forexKit = forexKit
        self.quickStorage = quickStorage
    }

    private static func makeForexKit(withStorage storage: ValutaConversionQuickStoragable) -> ForexKit {
        var forexKitConfiguration: ForexKitConfiguration?
        if let forexAPIURL = SecretsJSON.shared.content?.forexAPIURL {
            forexKitConfiguration = .init(container: storage, forexBaseURL: forexAPIURL)
        }
        return ForexKit(configuration: forexKitConfiguration ?? ForexKitConfiguration(container: storage))
    }
}
