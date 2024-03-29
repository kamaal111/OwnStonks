//
//  ICloudNotifications.swift
//
//
//  Created by Kamaal M Farah on 23/12/2023.
//

import CloudKit
import SwiftData
import SharedUtils
import KamaalCloud
import KamaalLogger

final class ICloudNotifications {
    private let cloud = KamaalCloud(
        containerID: SharedConfig.iCloudContainerID,
        databaseType: .private
    )
    private let subscriptionsWanted = [
        "CD_StoredTransaction-changes",
        "CD_StoredTransactionDataSource-changes",
    ]
    private let logger = KamaalLogger(from: ICloudNotifications.self, failOnError: true)

    private var subscriptions: [CKSubscription] = []

    func subscripeToAll() async throws {
        let fetchedSubscriptions = try await fetchAllSubcriptions()
        let fetchedSubscriptionsAsRecordTypes: [CKRecord.RecordType] = fetchedSubscriptions
            .compactMap { query in (query as? CKQuerySubscription)?.recordType }
        let subscriptionsToSubscribeTo = subscriptionsWanted
            .filter { subscription in !fetchedSubscriptionsAsRecordTypes.contains(subscription) }
            .map { subscription in subscription.split(separator: "-").dropLast().joined(separator: "-") }
        let subscribedSubsctiptions = await subscribeToChanges(subscriptionsToSubscribeTo)
        let subscriptions = fetchedSubscriptions + subscribedSubsctiptions
        self.subscriptions = subscriptions
        logger.info(
            "Subscribed iCloud subscriptions; \(subscriptions.map { subscription in subscription.subscriptionID })"
        )
    }

    private func subscribeToChanges(_ subscriptionsToSubscribeTo: [String]) async -> [CKSubscription] {
        do {
            return try await cloud.subscriptions.subscribeToChanges(ofTypes: subscriptionsToSubscribeTo).get()
        } catch {
            logger.error(label: "Failed to subscribe to changes", error: error)
            return []
        }
    }

    private func fetchAllSubcriptions() async throws -> [CKSubscription] {
        try await cloud.subscriptions.fetchAllSubscriptions().get()
    }
}
