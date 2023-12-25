//
//  PersistentData.swift
//
//
//  Created by Kamaal M Farah on 10/12/2023.
//

import CloudKit
import SwiftData
import Foundation
import KamaalCloud
import SharedUtils

/// Utility class to rfetch, insert, and delete models.
public final class PersistentData: PersistentDatable {
    public let dataContainer: ModelContainer
    public let cloudContainer: KamaalCloud? = KamaalCloud(
        containerID: SharedConfig.iCloudContainerID,
        databaseType: .private
    )

    private init() {
        let schema = Schema([StoredTransaction.self])
        #if targetEnvironment(simulator)
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        #else
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .automatic
        )
        #endif
        do {
            self.dataContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Failed to get data container; error='\(error)'")
        }
    }

    /// Main shared instance of ``PersistentData/PersistentData``.
    public static let shared = PersistentData()

    public func filterICloud(
        of record: CloudQueryable.Type,
        by predicate: NSPredicate,
        limit: Int? = nil
    ) async throws -> [CKRecord] {
        guard let cloudContainer else {
            assertionFailure("Expected cloud container not to be nil")
            return []
        }

        return try await cloudContainer.objects
            .filter(ofType: record.recordName, by: predicate, limit: limit)
            .get()
    }
}
