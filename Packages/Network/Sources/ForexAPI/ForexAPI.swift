//
//  ForexAPI.swift
//  
//
//  Created by Kamaal M Farah on 01/01/2023.
//

import Models
import Swinject
import XiphiasNet
import Foundation

private let BASE_URL = URL(string: "https://theforexapi.com/api")!

public class ForexAPI {
    private let urlSession: URLSession
    private let preview: Bool

    convenience init(preview: Bool = false) {
        self.init(preview: preview, urlSession: .shared)
    }

    init(preview: Bool, urlSession: URLSession) {
        self.urlSession = urlSession
        self.preview = preview
    }

    public func latest() async -> Result<ExchangeRates, Errors> {
        guard !preview else { return .success(.preview) }

        let url = BASE_URL
            .appendingPathComponent("latest")
        let config = XRequestConfig(priority: XRequestConfig.defaultPriority, kowalskiAnalysis: false)
        return await networker.request(from: url, headers: defaultHeaders, config: config)
            .mapError({ Errors.fromXiphiasNet($0) })
            .map(\.data)
    }

    public static let shared = ForexAPI()

    public static let preview = ForexAPI(preview: true)

    private var defaultHeaders: [String: String] {
        [:]
    }

    private var networker: XiphiasNet {
        container.resolve(XiphiasNet.self, argument: urlSession)!
    }
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
                return .generalError(context: error)
            case .responseError(message: let message, code: let code):
                return .responseError(message: message, code: code)
            case .notAValidJSON:
                return .notAValidJSON
            case .parsingError:
                return .parsingError(context: error)
            case .invalidURL(url: let url):
                return .invalidURL(url: url)
            }
        }
    }
}
