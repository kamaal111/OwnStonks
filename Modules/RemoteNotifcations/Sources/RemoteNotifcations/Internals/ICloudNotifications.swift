//
//  ICloudNotifications.swift
//
//
//  Created by Kamaal M Farah on 23/12/2023.
//

import CloudKit
import KamaalCloud
import KamaalLogger

final class ICloudNotifications {
    private let cloud = KamaalCloud(
        containerID: "iCloud.com.io.kamaal.OwnStonks",
        databaseType: .private
    )
    private let subscriptionsWanted = [
        "CD_StoredTransaction",
    ]
    private let logger = KamaalLogger(from: ICloudNotifications.self, failOnError: true)

    private var subscriptions: [CKSubscription] = []

    func subscripeToAll() async {
        let fetchedSubscriptions = await fetchAllSubcriptions()
        let fetchedSubscriptionsAsRecordTypes: [CKRecord.RecordType] = fetchedSubscriptions
            .compactMap { query in (query as? CKQuerySubscription)?.recordType }
        let subscriptionsToSubscribeTo = subscriptionsWanted
            .filter { subscription in !fetchedSubscriptionsAsRecordTypes.contains(subscription) }
        let subscribedSubsctiptions = await subscribeToChanges(subscriptionsToSubscribeTo)
        let subscriptions = fetchedSubscriptions + subscribedSubsctiptions
        self.subscriptions = subscriptions
        logger.info("Subscribed iCloud subscriptions; \(subscriptions)")
    }

    private func subscribeToChanges(_ subscriptionsToSubscribeTo: [String]) async -> [CKSubscription] {
        do {
            return try await cloud.subscriptions.subscribeToChanges(ofTypes: subscriptionsToSubscribeTo).get()
        } catch {
            logger.error(label: "Failed to subscribe to changes", error: error)
            return []
        }
    }

    private func fetchAllSubcriptions() async -> [CKSubscription] {
        do {
            return try await cloud.subscriptions.fetchAllSubscriptions().get()
        } catch {
            logger.error(label: "Failed to fetch all subscriptions", error: error)
            return []
        }
    }
}
