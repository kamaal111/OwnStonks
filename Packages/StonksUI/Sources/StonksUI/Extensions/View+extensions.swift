//
//  View+extensions.swift
//  
//
//  Created by Kamaal Farah on 14/06/2021.
//

import SwiftUI

extension View {

    /// A view that pads this view inside the specified edge insets with a system-calculated amount of padding,
    /// with enumarised sizes
    /// - Parameters:
    ///   - edges: The set of edges along which to pad this view. The default is Edge/Set/all.
    ///   - size: The preffered size of padding chosen from a enum with sizes
    /// - Returns: A view that pads this view using the specified edge insets with specified amount of padding.
     public func padding(_ edges: Edge.Set = .all, size: StonksStyles.Sizes) -> some View {
        self.padding(edges, size.rawValue)
    }

}
