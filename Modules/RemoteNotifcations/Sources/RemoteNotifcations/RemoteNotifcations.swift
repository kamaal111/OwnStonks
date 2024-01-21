//
//  RemoteNotifcations.swift
//
//
//  Created by Kamaal M Farah on 23/12/2023.
//

import KamaalUtils

/// Utility class to deal with remote notifications
public final class RemoteNotifcations {
    private let iCloud = ICloudNotifications()

    private init() { }

    /// Subscribe to all remote notifications.
    public func subscripeToAll() async throws {
        try await Retrier.retryUntilSuccess(intervalTimeInSeconds: 5) {
            try await iCloud.subscripeToAll()
        }
    }

    /// Singleton instance of ``RemoteNotifcations/RemoteNotifcations``.
    public static let shared = RemoteNotifcations()
}
