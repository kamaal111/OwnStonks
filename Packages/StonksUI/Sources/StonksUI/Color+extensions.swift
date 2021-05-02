//
//  Color+extensions.swift
//  
//
//  Created by Kamaal M Farah on 02/05/2021.
//

import SwiftUI

#if canImport(UIKit)
public extension Color {
    static let StonkBackground = Color(.systemBackground)
}
#else
public extension Color {
    static let StonkBackground = Color(.controlBackgroundColor)
}
#endif
