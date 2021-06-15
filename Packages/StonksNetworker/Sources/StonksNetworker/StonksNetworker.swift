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
    public let baseURL = URL(staticString: "http://127.0.0.1:8000")

    private let networker = XiphiasNet(kowalskiAnalysis: true)

    public init() { }

    @available(macOS 12.0, *)
    public func getRoot() async -> Result<RootResponse?, Error> {
        await withUnsafeContinuation({ (task: UnsafeContinuation<Result<RootResponse?, Error>, Never>) in
            networker.request(from: baseURL) { (result: Result<RootResponse?, Error>) in
                task.resume(returning: result)
            }
        })
    }
}

public struct RootResponse: Codable {
    public let hello: String
}
