//
//  PersistentDatable.swift
//
//
//  Created by Kamaal M Farah on 10/12/2023.
//

import SwiftData
import Foundation

/// Protocol to manage SwiftData objects.
public protocol PersistentDatable {
    /// An object that manages an app’s schema and model storage configuration.
    var dataContainer: ModelContainer { get }
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
    public func filter<T: PersistentModel>(predicate: Predicate<T>?, sorts: [SortDescriptor<T>] = []) throws -> [T] {
        var fetch = FetchDescriptor<T>(predicate: predicate)
        fetch.includePendingChanges = false
        fetch.sortBy = sorts
        return try dataContainerContext.fetch(fetch)
    }

    /// List objects.
    /// - Parameter sorts: The sorting descriptors to sort by.
    /// - Returns: Listed objects.
    @MainActor
    public func list<T: PersistentModel>(sorts: [SortDescriptor<T>] = []) throws -> [T] {
        try filter(predicate: nil, sorts: sorts)
    }
}
