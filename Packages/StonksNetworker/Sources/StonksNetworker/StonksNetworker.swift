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
