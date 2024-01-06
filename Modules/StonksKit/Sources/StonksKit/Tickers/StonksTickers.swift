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
                .init(name: "date", value: String(date.beginningOfDay.toIsoString().split(separator: "T")[0])),
            ])
        return await get(url: url, enableCaching: true)
            .mapError(StonksTickersErrors.fromNetworker(_:))
    }

//    public func closes(for ticker: String)

    public func tickerIsValid(_ ticker: String) async -> Result<Bool, StonksTickersErrors> {
        let result = await info(for: ticker, date: Date())
        let isFound: Bool
        switch result {
        case let .failure(failure):
            switch failure {
            case .notFound: isFound = false
            case .badRequest: return .failure(failure)
            case .general: return .failure(failure)
            }
        case .success: isFound = true
        }
        return .success(isFound)
    }

    private var clientURL: URL {
        Self.BASE_URL
            .appending(path: "tickers")
    }
}

extension Date {
    fileprivate var beginningOfDay: Date {
        let dateComponents = Calendar.current.dateComponents([.day, .year, .month], from: self)
        guard let hashedDate = Calendar.current.date(from: dateComponents) else {
            assertionFailure("Failed to hash date")
            return Date()
        }

        return hashedDate
    }
}
