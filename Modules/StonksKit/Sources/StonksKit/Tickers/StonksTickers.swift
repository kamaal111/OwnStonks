//
//  StonksTickers.swift
//
//
//  Created by Kamaal M Farah on 01/01/2024.
//

import Foundation
import KamaalUtils
import KamaalExtensions

public class StonksTickers: StonksKitClient {
    public func info(
        for ticker: String,
        date: Date
    ) async -> Result<StonksTickersInfoResponse, StonksTickersErrors> {
        let url = clientURL
            .appending(path: "info")
            .appending(path: ticker)
            .appending(queryItems: [
                .init(name: "date", value: Self.dateFormatter.string(from: date)),
            ])
        return await get(url: url, enableCaching: true)
            .mapError(StonksTickersErrors.fromNetworker(_:))
    }

    public func closes(for ticker: String, startDate: Date) async -> Result<[String: Double], StonksTickersErrors> {
        let url = clientURL
            .appending(path: "closes")
            .appending(path: ticker)
            .appending(queryItems: [
                .init(name: "start_date", value: Self.dateFormatter.string(from: startDate)),
            ])
        return await get(url: url, enableCaching: false)
            .mapError(StonksTickersErrors.fromNetworker(_:))
    }

    public func tickerIsValid(_ ticker: String) async -> Result<Bool, StonksTickersErrors> {
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

    private var clientURL: URL {
        Self.BASE_URL
            .appending(path: "tickers")
    }

    private static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.locale = Locale(identifier: "en_UK")
        return dateFormatter
    }()
}
