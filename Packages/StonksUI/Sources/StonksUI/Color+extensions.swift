//
//  Color+extensions.swift
//  
//
//  Created by Kamaal M Farah on 02/05/2021.
//

import SwiftUI

#if canImport(UIKit)
extension Color {
    public static let StonkBackground = Color(.systemBackground)
}
#else
extension Color {
    public static let StonkBackground = Color(.controlBackgroundColor)
}
#endif
