//
//  StonksTickers.swift
//
//
//  Created by Kamaal M Farah on 01/01/2024.
//

import Combine
import Foundation
import KamaalUtils
import KamaalNetworker
import KamaalExtensions

public final class StonksTickers: StonksKitClient {
    private var cancellables: Set<AnyCancellable> = []

    public func info(
        for tickers: [String],
        date: Date
    ) async -> Result<[String: StonksTickersInfoResponse], StonksTickersErrors> {
        await cacheStorage.withStonksInfoCache(tickers: tickers, date: date) { remainingTickers in
            let symbols = remainingTickers.joined(separator: ",")
            let url = clientURL
                .appending(path: "info")
                .appending(queryItems: [
                    .init(name: "symbols", value: symbols),
                    .init(name: "date", value: formatDate(date)),
                ])
            let result = await withCheckedContinuation { (continuation: CheckedContinuation<
                Result<[String: StonksTickersInfoResponse], StonksTickersErrors>,
                Never
            >) in
                getPublisher(url: url, ofType: [String: StonksTickersInfoResponse].self)
                    .sink(receiveCompletion: { completion in
                        switch completion {
                        case .finished: break
                        case let .failure(failure):
                            continuation.resume(returning: .failure(StonksTickersErrors.fromNetworker(failure)))
                        }
                    }, receiveValue: { value in
                        let response: [String: StonksTickersInfoResponse]
                        do {
                            response = try JSONDecoder().decode([String: StonksTickersInfoResponse].self, from: value)
                        } catch {
                            assertionFailure("Should not fail here as it was encoded from this type")
                            continuation.resume(returning: .failure(.general(context: error)))
                            return
                        }
                        continuation.resume(returning: .success(response))
                    })
                    .store(in: &cancellables)
            }
            completeGetPublisher(for: url)
            return result
        }
    }

    public func info(for ticker: String, date: Date) async -> Result<StonksTickersInfoResponse, StonksTickersErrors> {
        let result = await info(for: [ticker], date: date)
        let infos: [String: StonksTickersInfoResponse]
        switch result {
        case let .failure(failure): return .failure(failure)
        case let .success(success): infos = success
        }
        guard let info = infos[ticker] else { return .failure(.notFound(context: nil)) }

        return .success(info)
    }

    public func closes(
        for tickers: [String],
        startDate: Date
    ) async -> Result<[String: StonksTickersClosesResponse], StonksTickersErrors> {
        let endDate = Date()
        return await cacheStorage.withStonksClosesCache(
            tickers: tickers,
            startDate: startDate,
            endDate: endDate
        ) { remainingTickers in
            let url = clientURL
                .appending(path: "closes")
                .appending(queryItems: [
                    .init(name: "symbols", value: remainingTickers.joined(separator: ",")),
                    .init(name: "start_date", value: formatDate(startDate)),
                    .init(name: "end_date", value: formatDate(endDate)),
                ])
            return await get(url: url, ofType: [String: StonksTickersClosesResponse].self)
                .mapError { error in StonksTickersErrors.fromNetworker(error) }
        }
    }

    public func closes(
        for ticker: String,
        startDate: Date
    ) async -> Result<StonksTickersClosesResponse, StonksTickersErrors> {
        let result = await closes(for: [ticker], startDate: startDate)
        let closes: [String: StonksTickersClosesResponse]
        switch result {
        case let .failure(failure): return .failure(failure)
        case let .success(success): closes = success
        }
        guard let tickerResponse = closes[ticker] else { return .failure(.notFound(context: nil)) }

        return .success(tickerResponse)
    }

    public func tickerIsValid(_ ticker: String) async -> Result<Bool, StonksTickersErrors> {
        if cacheStorage.getStonksInfoCache(ticker: ticker, date: nil) != nil {
            return .success(true)
        }

        let result = await info(for: ticker, date: Date())
        let isFound: Bool
        switch result {
        case let .failure(failure):
            switch failure {
            case .notFound: isFound = false
            case .badRequest, .general: return .failure(failure)
            }
        case .success: isFound = true
        }
        return .success(isFound)
    }

    private func formatDate(_ date: Date) -> String {
        Self.dateFormatter.string(from: date)
    }

    private var clientURL: URL {
        baseURL
            .appending(path: "tickers")
    }

    private static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }()
}
