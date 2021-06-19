//
//  StonksNetworker.swift
//  
//
//  Created by Kamaal Farah on 14/06/2021.
//

import Foundation
import ShrimpExtensions
import XiphiasNet

public struct StonksNetworker {
    private let networker = XiphiasNet(kowalskiAnalysis: true)

    public init() { }

    @available(iOS 15.0, *)
    public func getInfo(of symbol: String) async -> Result<[String: InfoResponse]?, Error> {
        await asyncRequest(from: .info(of: symbol))
    }

    @available(macOS 12.0, iOS 15.0, *)
    public func getRoot() async -> Result<RootResponse?, Error> {
        await asyncRequest(from: .root)
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

    static var root: Self {
        Endpoint(path: "")
    }

    static func info(of symbol: String) -> Self {
        Endpoint(path: "info/\(symbol)")
    }
}

public struct RootResponse: Codable {
    public let hello: String
}

public struct InfoResponse: Codable {
    public let currency: String?
    public let logoUrl: URL?
    public let longName: String?
    public let previousClose: Double
    public let shortName: String?
    public let symbol: String

    public init(currency: String?, logoUrl: URL?, longName: String?, previousClose: Double, shortName: String?, symbol: String) {
        self.currency = currency
        self.logoUrl = logoUrl
        self.longName = longName
        self.previousClose = previousClose
        self.shortName = shortName
        self.symbol = symbol
    }

    public enum CodingKeys: String, CodingKey {
        case currency
        case logoUrl = "logo_url"
        case longName = "long_name"
        case previousClose = "previous_close"
        case shortName = "short_name"
        case symbol
    }
}
