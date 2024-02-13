//
//  BaseStonksKitClient.swift
//
//
//  Created by Kamaal M Farah on 01/01/2024.
//

import Combine
import Foundation
import KamaalNetworker
import KamaalExtensions

/// StonksKit client base type
public typealias StonksKitClient = BaseStonksKitClient & StonkKitClientable

/// StonksKit client protocol
public protocol StonkKitClientable { }

/// StonksKit client base class
public class BaseStonksKitClient {
    private let networker: KamaalNetworker
    var cacheStorage: StonksKitCacheStorable
    let baseURL: URL
    private var getRequestPublishers: [URL: AnyPublisher<Data, KamaalNetworker.Errors>] = [:]

    init(baseURL: URL, networker: KamaalNetworker, cacheStorage: StonksKitCacheStorable) {
        self.baseURL = baseURL
        self.networker = networker
        self.cacheStorage = cacheStorage
    }

    func getPublisher<T: Codable>(url: URL, ofType type: T.Type) -> AnyPublisher<Data, KamaalNetworker.Errors> {
        if let publisher = getRequestPublishers[url] {
            return publisher
        }

        let publisher = Future<Data, KamaalNetworker.Errors> { [self] promise in
            Task {
                let result = await get(url: url, ofType: type)
                let response: T
                switch result {
                case let .failure(failure):
                    promise(.failure(failure))
                    return
                case let .success(success): response = success
                }

                let dataResponse: Data
                do {
                    dataResponse = try JSONEncoder().encode(response)
                } catch {
                    assertionFailure("Should not fail here because its encoded from a valid JSON")
                    promise(.failure(.parsingError(error: error)))
                    return
                }
                promise(.success(dataResponse))
            }
        }
        .share()
        .eraseToAnyPublisher()
        getRequestPublishers[url] = publisher
        return publisher
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

    func completeGetPublisher(for url: URL) {
        getRequestPublishers[url] = nil
    }

    private var defaultHeader: [String: String] {
        [:]
    }
}
