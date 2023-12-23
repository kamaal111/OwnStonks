//
//  RemoteNotifcations.swift
//
//
//  Created by Kamaal M Farah on 23/12/2023.
//

/// Utility class to deal with remote notifications
public final class RemoteNotifcations {
    private let iCloud = ICloudNotifications()

    private init() { }

    /// Subscribe to all remote notifications.
    public func subscripeToAll() async {
        await iCloud.subscripeToAll()
    }

    /// Singleton instance of ``RemoteNotifcations/RemoteNotifcations``.
    public static let shared = RemoteNotifcations()
}
