//
//  StonksNetworker.swift
//  
//
//  Created by Kamaal Farah on 14/06/2021.
//

import Foundation
import ShrimpExtensions
import XiphiasNet

/// An struct to make calls to the stonks API
public struct StonksNetworker {
    private let networker = XiphiasNet(kowalskiAnalysis: false)

    /// `StonksNetworker` initializer
    public init() { }

    /// Get info of given symbols
    /// - Parameters:
    ///   - symbols: stock symbols
    ///   - queryItems: url query items to query specific items
    /// - Returns: an result with an optional dictionary of the symbol as key and `InfoResponse` as value on success and
    /// an `Error` on failure
    @available(macOS 12.0, iOS 15.0, *)
    public func getInfo(
        of symbols: [String],
        with queryItems: [URLQueryItem]) async -> Result<[String: InfoResponse]?, Error> {
        await asyncRequest(from: .info(of: symbols.joined(separator: ","), with: queryItems))
    }

    @available(macOS 12.0, iOS 15.0, *)
    private func asyncRequest<T: Codable>(from endpoint: Endpoint) async -> Result<T?, Error> {
        await withUnsafeContinuation({ (task: UnsafeContinuation<Result<T?, Error>, Never>) in
            networker.request(from: endpoint.url) { (result: Result<T?, Error>) in
                task.resume(returning: result)
            }
        })
    }
}

struct Endpoint {
    let path: String
    let queryItems: [URLQueryItem]

    private let baseURL = URL(staticString: "http://127.0.0.1:8000")

    init(path: String, queryItems: [URLQueryItem] = []) {
        self.path = path
        self.queryItems = queryItems
    }

    var url: URL {
        let urlWithPath = baseURL.appendingPathComponent("/\(path)")
        guard var components = URLComponents(string: urlWithPath.absoluteString) else {
            fatalError("Could not initialize components")
        }
        components.queryItems = queryItems
        guard let componentsURL = components.url else {
            fatalError("Invalid URL components: \(components)")
        }
        return componentsURL
    }

    static func info(of symbols: String, with queryItems: [URLQueryItem] = []) -> Self {
        Endpoint(path: "info/\(symbols)", queryItems: queryItems)
    }
}

public struct InfoResponse: Codable {
    public let currency: String?
    public let logoUrl: URL?
    public let longName: String?
    public let close: Double
    public let shortName: String?
    public let symbol: String

    public init(
        currency: String?,
        logoUrl: URL?,
        longName: String?,
        close: Double,
        shortName: String?,
        symbol: String) {
        self.currency = currency
        self.logoUrl = logoUrl
        self.longName = longName
        self.close = close
        self.shortName = shortName
        self.symbol = symbol
    }

    public enum CodingKeys: String, CodingKey {
        case currency
        case logoUrl = "logo_url"
        case longName = "long_name"
        case close = "close"
        case shortName = "short_name"
        case symbol
    }
}
