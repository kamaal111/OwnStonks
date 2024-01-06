//
//  PersistentStorable.swift
//
//
//  Created by Kamaal M Farah on 06/01/2024.
//

import SwiftData

public protocol PersistentStorable: PersistentModel {
    associatedtype Payload

    func update(payload: Payload) throws -> Self

    static func create(payload: Payload, context: ModelContext?) throws -> Self
}

extension PersistentStorable {
    public func delete() {
        assert(modelContext != nil)
        modelContext?.delete(self)
    }
}
