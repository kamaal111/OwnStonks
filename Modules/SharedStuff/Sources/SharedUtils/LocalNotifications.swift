//
//  LocalNotifications.swift
//
//
//  Created by Kamaal M Farah on 23/12/2023.
//

import Foundation
import KamaalLogger

public enum LocalNotificationEvents: String {
    case iCloudChanges

    var notificationName: Notification.Name {
        Notification.Name("io.kamaal.LocalNotifications.notifications.\(rawValue)")
    }
}

public final class LocalNotifications {
    private let logger = KamaalLogger(from: LocalNotifications.self, failOnError: true)

    private init() { }

    public func emit(_ event: LocalNotificationEvents, withObject object: Any? = nil) {
        NotificationCenter.default.post(name: event.notificationName, object: object)
        logger.info("Notification \(event) emited with data: \(object as Any)")
    }

    public static let shared = LocalNotifications()
}
