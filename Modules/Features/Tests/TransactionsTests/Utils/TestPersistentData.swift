//
//  TestPersistentData.swift
//
//
//  Created by Kamaal M Farah on 10/12/2023.
//

import SwiftData
import PersistentData

final class TestPersistentData: PersistentDatable {
    var dataContainer: ModelContainer

    init() throws {
        let schema = Schema([StoredTransaction.self])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        self.dataContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
    }
}
