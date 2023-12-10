//
//  PersistentDatable.swift
//
//
//  Created by Kamaal M Farah on 10/12/2023.
//

import SwiftData
import Foundation

public protocol PersistentDatable {
    var dataContainer: ModelContainer { get }
}

extension PersistentDatable {
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
