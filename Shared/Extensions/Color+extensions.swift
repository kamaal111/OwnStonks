//
//  Color+extensions.swift
//  OwnStonks
//
//  Created by Kamaal M Farah on 01/05/2021.
//

import SwiftUI

#if canImport(UIKit)
extension Color {
    static let MainBackground = Color(.systemBackground)
}
#else
extension Color {
    static let MainBackground = Color(.controlBackgroundColor)
}
#endif
