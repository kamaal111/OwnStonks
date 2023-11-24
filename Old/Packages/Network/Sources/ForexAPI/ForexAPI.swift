//
//  ForexAPI.swift
//
//
//  Created by Kamaal M Farah on 01/01/2023.
//

import Models
import XiphiasNet
import Foundation

private let BASE_URL = URL(string: "https://theforexapi.com/api")!

public class ForexAPI {
    private let preview: Bool
    private let networker: XiphiasNet

    convenience init(preview: Bool = false) {
        self.init(preview: preview, urlSession: .shared)
    }

    public init(preview: Bool, urlSession: URLSession) {
        self.preview = preview
        self.networker = XiphiasNet(urlSession: urlSession)
    }

    public func latest(base: Currencies, symbols: [Currencies]) async -> Result<ExchangeRates, Errors> {
        guard !preview else { return .success(.preview) }

        let url = BASE_URL
            .appendingPathComponent("latest")
        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        var queryItems = [
            URLQueryItem(name: "base", value: base.rawValue),
        ]
        let symbols = symbols.filter { $0 != base }
        if !symbols.isEmpty {
            queryItems.append(URLQueryItem(name: "symbols", value: symbols.map(\.rawValue).joined(separator: ",")))
        }
        urlComponents.queryItems = queryItems

        return await networker.request(from: urlComponents.url!)
            .mapError { .fromXiphiasNet($0) }
            .map(\.data)
    }

    public static let shared = ForexAPI()

    public static let preview = ForexAPI(preview: true)
}

extension ForexAPI {
    public enum Errors: Error {
        case generalError(context: Error)
        case responseError(message: String, code: Int)
        case notAValidJSON
        case parsingError(context: Error)
        case invalidURL(url: String)

        fileprivate static func fromXiphiasNet(_ error: XiphiasNet.Errors) -> Errors {
            switch error {
            case .generalError:
                .generalError(context: error)
            case let .responseError(message: message, code: code):
                .responseError(message: message, code: code)
            case .notAValidJSON:
                .notAValidJSON
            case .parsingError:
                .parsingError(context: error)
            case let .invalidURL(url: url):
                .invalidURL(url: url)
            }
        }

        fileprivate var stringified: String {
            switch self {
            case let .generalError(context: context):
                "general_error_\(context)"
            case let .responseError(message: message, code: code):
                "response_error_\(message)_\(code)"
            case .notAValidJSON:
                "not_valid_json"
            case let .parsingError(context: context):
                "parsing_error_\(context)"
            case let .invalidURL(url: url):
                "invalid_url_\(url)"
            }
        }
    }
}

extension ForexAPI.Errors: Equatable {
    public static func == (lhs: ForexAPI.Errors, rhs: ForexAPI.Errors) -> Bool {
        lhs.stringified == rhs.stringified
    }
}
