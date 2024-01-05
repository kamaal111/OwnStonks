//
//  AppDelegate_iOS.swift
//  OwnStonks
//
//  Created by Kamaal M Farah on 23/12/2023.
//

#if os(iOS)
import UIKit
import CloudKit
import SharedUtils
import RemoteNotifcations

final class AppDelegate: NSObject {
    private let userNotificationCenter: UNUserNotificationCenter = .current()
}

extension AppDelegate: UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        application.registerForRemoteNotifications()

        #if !targetEnvironment(simulator)
        Task { await RemoteNotifcations.shared.subscripeToAll() }
        #endif

        return true
    }

    func application(
        _: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        if let notification = CKNotification(fromRemoteNotificationDictionary: userInfo) {
            LocalNotifications.shared.emit(.iCloudChanges, withObject: notification)
            completionHandler(.newData)
        }
    }
}
#endif
