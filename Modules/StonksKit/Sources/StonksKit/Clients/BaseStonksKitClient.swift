//
//  BaseStonksKitClient.swift
//
//
//  Created by Kamaal M Farah on 01/01/2024.
//

import Foundation
import KamaalNetworker
import KamaalExtensions

public typealias StonksKitClient = BaseStonksKitClient & StonkKitClientable

public protocol StonkKitClientable { }

public class BaseStonksKitClient {
    private let networker: KamaalNetworker
    var cacheStorage: StonksKitCacheStorable

    static let BASE_URL = URL(staticString: "http://127.0.0.1:8000")

    init(networker: KamaalNetworker, cacheStorage: StonksKitCacheStorable) {
        self.networker = networker
        self.cacheStorage = cacheStorage
    }

    func get<T: Codable>(url: URL) async -> Result<T, KamaalNetworker.Errors> {
        let result: Result<T, KamaalNetworker.Errors> = await networker.request(
            from: url,
            headers: defaultHeader,
            config: .init(kowalskiAnalysis: false)
        )
        .map { success in success.data }
        let successfulResponse: T
        switch result {
        case .failure: return result
        case let .success(success): successfulResponse = success
        }

        return .success(successfulResponse)
    }

    func get<T: Codable>(url: URL, ofType _: T.Type) async -> Result<T, KamaalNetworker.Errors> {
        await get(url: url)
    }

    private var defaultHeader: [String: String] {
        [:]
    }
}
