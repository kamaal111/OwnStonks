//
//  PersistentData.swift
//
//
//  Created by Kamaal M Farah on 10/12/2023.
//

import SwiftData
import Foundation

/// Utility class to rfetch, insert, and delete models.
public final class PersistentData {
    /// An object that manages an app’s schema and model storage configuration.
    public let dataContainer: ModelContainer

    private init() {
        let schema = Schema([StoredTransaction.self])
        let modelConfiguration = ModelConfiguration(schema: schema)
        do {
            self.dataContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Failed to get data container; error='\(error)'")
        }
    }

    /// Main shared instance of ``PersistentData/PersistentData``.
    public static let shared = PersistentData()

    /// An object that enables you to fetch, insert, and delete models, and save any changes to disk.
    @MainActor
    public var dataContainerContext: ModelContext {
        dataContainer.mainContext
    }

    @MainActor
    public func filter<T: PersistentModel>(predicate: Predicate<T>?) throws -> [T] {
        var fetch = FetchDescriptor<T>(predicate: predicate)
        fetch.includePendingChanges = true
        return try dataContainerContext.fetch(fetch)
    }

    @MainActor
    public func list<T: PersistentModel>() throws -> [T] {
        try filter(predicate: nil)
    }
}
