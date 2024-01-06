//
//  BaseStonksKitClient.swift
//
//
//  Created by Kamaal M Farah on 01/01/2024.
//

import Foundation
import KamaalUtils
import KamaalNetworker
import KamaalExtensions

public class BaseStonksKitClient {
    private let networker: KamaalNetworker

    static let BASE_URL = URL(staticString: "http://127.0.0.1:8000")

    init(networker: KamaalNetworker) {
        self.networker = networker
    }

    var defaultHeader: [String: String] {
        [:]
    }

    func get<T: Codable>(url: URL) async -> Result<T, KamaalNetworker.Errors> {
        if let stonksAPIGetCache = UserDefaults.stonksAPIGetCache,
           let cachedResult = stonksAPIGetCache[url],
           let cachedResponse = try? JSONDecoder().decode(T.self, from: cachedResult) {
            return .success(cachedResponse)
        }

        let result: Result<T, KamaalNetworker.Errors> = await networker.request(from: url, headers: defaultHeader)
            .map { success in success.data }
        let successfulResponse: T
        switch result {
        case .failure: return result
        case let .success(success): successfulResponse = success
        }

        if let responseData = try? JSONEncoder().encode(successfulResponse) {
            if UserDefaults.stonksAPIGetCache == nil {
                UserDefaults.stonksAPIGetCache = [url: responseData]
            } else {
                UserDefaults.stonksAPIGetCache?[url] = responseData
            }
        }
        return .success(successfulResponse)
    }
}

extension UserDefaults {
    @UserDefaultsObject(key: "io.kamaal.swift-stonks-api.get_cache")
    fileprivate static var stonksAPIGetCache: [URL: Data]?
}
