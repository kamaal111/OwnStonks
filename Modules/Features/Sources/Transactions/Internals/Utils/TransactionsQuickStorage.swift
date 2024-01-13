//
//  TransactionsQuickStorage.swift
//
//
//  Created by Kamaal M Farah on 24/12/2023.
//

import StonksKit
import Foundation
import KamaalUtils
import SharedUtils

protocol TransactionsQuickStoragable: StonksKitCacheStorable {
    var pendingCloudChanges: Bool { get set }
}

class TransactionsQuickStorage: TransactionsQuickStoragable {
    @UserDefaultsObject(key: makeKey("pending_cloud_changes"), container: UserDefaultsSuite.shared)
    private var _pendingCloudChanges: Bool?

    @UserDefaultsObject(key: makeKey("stonks_api_get_cache"), container: UserDefaultsSuite.shared)
    var stonksAPIGetCache: [URL: Data]?

    @UserDefaultsObject(key: makeKey("stonks_api_closes_cache"), container: UserDefaultsSuite.shared)
    var closesCache: [Date: [String: StonksTickersClosesResponse]]?

    private init() { }

    var pendingCloudChanges: Bool {
        get { _pendingCloudChanges ?? false }
        set { _pendingCloudChanges = newValue }
    }

    static let shared = TransactionsQuickStorage()

    private static func makeKey(_ key: String) -> String {
        "\(Constants.bundleIdentifier).\(key)"
    }
}
