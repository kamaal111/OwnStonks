//
//  TestPersistentData.swift
//
//
//  Created by Kamaal M Farah on 10/12/2023.
//

import CloudKit
import SwiftData
import KamaalCloud
import PersistentData

final class TestPersistentData: PersistentDatable {
    var dataContainer: ModelContainer
    var cloudContainer: KamaalCloud?

    var cloudResponse: [CKRecord] = []

    init() throws {
        let schema = Schema([StoredTransaction.self])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        self.dataContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
    }

    func filterICloud(
        of _: any CloudQueryable.Type,
        by _: NSPredicate,
        limit _: Int? = nil
    ) async throws -> [CKRecord] {
        cloudResponse
    }
}
