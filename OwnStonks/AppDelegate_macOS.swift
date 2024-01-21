//
//  AppDelegate_macOS.swift
//  OwnStonks
//
//  Created by Kamaal M Farah on 23/12/2023.
//

#if os(macOS)
import Cocoa
import CloudKit
import SharedUtils
import RemoteNotifcations

final class AppDelegate: NSObject { }

extension AppDelegate: NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        guard let application = notification.object as? NSApplication else { return }

        application.registerForRemoteNotifications()

        Task { try? await RemoteNotifcations.shared.subscripeToAll() }
    }

    func application(_: NSApplication, didReceiveRemoteNotification userInfo: [String: Any]) {
        if let notification = CKNotification(fromRemoteNotificationDictionary: userInfo) {
            LocalNotifications.shared.emit(.iCloudChanges, withObject: notification)
        }
    }
}
#endif
