//
//  StonksKit.swift
//
//
//  Created by Kamaal M Farah on 01/01/2024.
//

import Foundation
import KamaalNetworker

public struct StonksKit {
    public let health: StonksHealth
    public let tickers: StonksTickers

    public init() {
        self.init(networker: KamaalNetworker())
    }

    init(networker: KamaalNetworker) {
        self.health = .init(networker: networker)
        self.tickers = .init(networker: networker)
    }
}
