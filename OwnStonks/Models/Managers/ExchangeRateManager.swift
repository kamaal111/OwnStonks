//
//  ExchangeRateManager.swift
//  OwnStonks
//
//  Created by Kamaal M Farah on 01/01/2023.
//

import Models
import Logster
import Backend
import Swinject
import Foundation

private let logger = Logster(from: ExchangeRateManager.self)

final class ExchangeRateManager: ObservableObject {
    @Published private(set) var exchangeRates: ExchangeRates?

    private let preview: Bool

    init(preview: Bool = false) {
        self.preview = preview
    }

    func fetch() async {
        await benchmark(
            function: {
                logger.info("Fetching exchange rates")
                #warning("Handle error")
                let exchangeRates = try! await backend.forex.getLatest(base: .EUR, symbols: [.USD]).get()
                await setExchangeRates(exchangeRates)
            },
            duration: { duration in
                logger.info("Successfully fetched exchange rates in \((duration) * 1000) ms")
            })
    }

    private var backend: Backend {
        container.resolve(Backend.self, argument: preview)!
    }

    @MainActor
    private func setExchangeRates(_ exchangeRates: ExchangeRates?) {
        guard let exchangeRates else { return }

        self.exchangeRates = exchangeRates
    }

    private func benchmark<T>(function: () async -> T, duration: (_ duration: TimeInterval) -> Void) async -> T {
        #warning("Duplicate code")
        let info = ProcessInfo.processInfo
        let begin = info.systemUptime
        let result = await function()
        duration(info.systemUptime - begin)
        return result
    }
}
