//
//  Color+extensions.swift
//  OwnStonks
//
//  Created by Kamaal M Farah on 01/05/2021.
//

import SwiftUI

extension Color {
    #if canImport(UIKit)
    static let MainBackground = Color(.systemBackground)
    #else
    static let MainBackground = Color(.controlBackgroundColor)
    #endif
}
