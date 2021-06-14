//
//  View+extensions.swift
//  
//
//  Created by Kamaal Farah on 14/06/2021.
//

import SwiftUI

extension View {
     public func padding(_ edges: Edge.Set = .all, _ length: StonksStyles.Sizes) -> some View {
        self.padding(edges, length.rawValue)
    }
}
