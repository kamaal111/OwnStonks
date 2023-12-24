//
//  LocalizedItem.swift
//
//
//  Created by Kamaal M Farah on 10/12/2023.
//

import Foundation

/// A protocol to make sure the using type has a localized string property.
public protocol LocalizedItem {
    /// The localized string property.
    var localized: String { get }
}
