//
//  LocalNotifications.swift
//
//
//  Created by Kamaal M Farah on 23/12/2023.
//

import Foundation

/// Local notification events.
public enum LocalNotificationEvents: String {
    /// Notification event for when there are iCloud changes.
    /// This event most like includes a object of `CKNotification`.
    case iCloudChanges

    /// Notification name of the event.
    public var notificationName: Notification.Name {
        Notification.Name("io.kamaal.LocalNotifications.notifications.\(rawValue)")
    }
}

/// Utilitly class to handle local notifications.
public final class LocalNotifications {
    private let notificationCenter = NotificationCenter.default

    private init() { }

    /// Emit ``LocalNotificationEvents`` for observers.
    /// - Parameters:
    ///   - event: The event to emit.
    ///   - object: The optional object to emit with the event.
    public func emit(_ event: LocalNotificationEvents, withObject object: Any? = nil) {
        notificationCenter.post(name: event.notificationName, object: object)
    }

    /// Observe for local notification events.
    /// - Parameters:
    ///   - events: The events to observe to.
    ///   - selector: The selector that handles all the given events.
    ///   - obserserver: The observing object. In most cases `self`.
    public func observe(to events: [LocalNotificationEvents], selector: Selector, from obserserver: Any) {
        for event in events {
            notificationCenter.addObserver(obserserver, selector: selector, name: event.notificationName, object: nil)
        }
    }

    /// Remove all observers for the given ``LocalNotificationEvents``.
    /// - Parameters:
    ///   - events: The event to remove the observer for.
    ///   - observer: The observing object to remove the observers from. In most cases `self`.
    public func removeObservers(_ events: [LocalNotificationEvents], from observer: Any) {
        for event in events {
            notificationCenter.removeObserver(observer, name: event.notificationName, object: nil)
        }
    }

    /// Singleton object for ``LocalNotifications``.
    public static let shared = LocalNotifications()
}
