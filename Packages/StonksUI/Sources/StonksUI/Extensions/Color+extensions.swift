//
//  Color+extensions.swift
//  
//
//  Created by Kamaal M Farah on 02/05/2021.
//

import SwiftUI

extension Color {
    #if canImport(UIKit)
    /// App background color
    public static let StonkBackground = Color(.systemBackground)
    #else
    /// App background color
    public static let StonkBackground = Color(.controlBackgroundColor)
    #endif
    /// Background color of total section in `PortfolioScreen`
    public static let TotalsBackground = Color("TotalsBackground")
}
