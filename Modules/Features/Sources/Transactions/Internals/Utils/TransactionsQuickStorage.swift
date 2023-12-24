//
//  TransactionsQuickStorage.swift
//
//
//  Created by Kamaal M Farah on 24/12/2023.
//

import Foundation
import KamaalUtils
import SharedUtils

protocol TransactionsQuickStoragable {
    var pendingCloudChanges: Bool { get set }
}

class TransactionsQuickStorage: TransactionsQuickStoragable {
    @UserDefaultsObject(key: makeKey("pending_cloud_changes"), container: UserDefaultsSuite.shared)
    private var _pendingCloudChanges: Bool?

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
