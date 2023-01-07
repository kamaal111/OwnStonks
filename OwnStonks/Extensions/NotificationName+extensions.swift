//
//  NotificationName+extensions.swift
//  OwnStonks
//
//  Created by Kamaal M Farah on 07/01/2023.
//

import Foundation

extension Notification.Name {
    static let editModeChanged = makeNotificationName(withKey: "edit_mode_changed")

    private static func makeNotificationName(withKey key: String) -> Notification.Name {
        Notification.Name("io.kamaal.OwnStonks.notifications.\(key)")
    }
}
