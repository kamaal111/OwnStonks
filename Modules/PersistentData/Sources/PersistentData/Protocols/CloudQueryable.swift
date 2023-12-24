//
//  CloudQueryable.swift
//
//
//  Created by Kamaal M Farah on 24/12/2023.
//

import Foundation

/// Protocol to make the using type easier to query on from iCloud
public protocol CloudQueryable {
    /// The `CKRecord` name of the queryable object.
    static var recordName: String { get }
}
