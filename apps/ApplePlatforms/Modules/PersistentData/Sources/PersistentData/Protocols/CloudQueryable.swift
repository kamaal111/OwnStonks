//
//  CloudQueryable.swift
//
//
//  Created by Kamaal M Farah on 24/12/2023.
//

import Foundation

public protocol CloudKeyEnumable: CaseIterable & Hashable, RawRepresentable where RawValue == String { }

/// Protocol to make the using type easier to query on from iCloud
public protocol CloudQueryable {
    associatedtype CloudKeys: CloudKeyEnumable
    /// The `CKRecord` name of the queryable object.
    static var recordName: String { get }
}

extension CloudKeyEnumable {
    public var ckRecordKey: String {
        "CD_\(rawValue)"
    }
}
