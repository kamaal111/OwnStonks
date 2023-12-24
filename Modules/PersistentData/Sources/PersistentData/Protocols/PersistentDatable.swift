//
//  PersistentDatable.swift
//
//
//  Created by Kamaal M Farah on 10/12/2023.
//

import CloudKit
import SwiftData
import Foundation
import KamaalCloud

/// Protocol to manage SwiftData objects.
public protocol PersistentDatable {
    /// An object that manages an app’s schema and model storage configuration.
    var dataContainer: ModelContainer { get }

    /// An object that manages the iCloud objects.
    var cloudContainer: KamaalCloud? { get }

    /// Fetching and filtering iCloud objects.
    /// - Parameters:
    ///   - record: The ``CloudQueryable`` object to fetch for.
    ///   - predicate: The query to filter on.
    ///   - limit: The amount of items limit the response on.
    /// - Returns: A array of `CKRecord` containing the filtered on objects.
    func filterICloud(
        of record: CloudQueryable.Type,
        by predicate: NSPredicate,
        limit: Int?
    ) async throws -> [CKRecord]
}

extension PersistentDatable {
    /// An object that enables you to fetch, insert, and delete models, and save any changes to disk.
    @MainActor
    public var dataContainerContext: ModelContext {
        dataContainer.mainContext
    }

    /// Filter and list objects.
    /// - Parameters:
    ///   - predicate: The query predicate to filter on.
    ///   - sorts: The sorting descriptors to sort by.
    /// - Returns: Filtered objects based on the given predicate.
    @MainActor
    public func filter<T: PersistentModel>(predicate: Predicate<T>?, sorts: [SortDescriptor<T>]) throws -> [T] {
        var fetch = FetchDescriptor<T>(predicate: predicate)
        fetch.includePendingChanges = true
        fetch.sortBy = sorts
        return try dataContainerContext.fetch(fetch)
    }

    /// List objects.
    /// - Parameter sorts: The sorting descriptors to sort by.
    /// - Returns: Listed objects.
    @MainActor
    public func list<T: PersistentModel>(sorts: [SortDescriptor<T>]) throws -> [T] {
        try filter(predicate: nil, sorts: sorts)
    }

    /// List iCloud objects.
    /// - Parameter record: The ``CloudQueryable`` object to fetch for.
    /// - Returns: A array of `CKRecord` containing the filtered on objects.
    public func listICloud(of record: CloudQueryable.Type) async throws -> [CKRecord] {
        let predicate = NSPredicate(value: true)
        return try await filterICloud(of: record, by: predicate, limit: nil)
    }
}
