//
//  ValutaConversionEnvironmentModifier.swift
//
//
//  Created by Kamaal M Farah on 16/12/2023.
//

import SwiftUI

extension View {
    /// The environment view modifier that gives all the ``ValutaConversion`` its context.
    /// - Returns: A modified view with the ``ValutaConversion`` feature context.
    public func valutaConversionEnvironment() -> some View {
        modifier(ValutaConversionEnvironmentModifier())
    }
}

private struct ValutaConversionEnvironmentModifier: ViewModifier {
    @State private var valutaConversion = ValutaConversion()

    func body(content: Content) -> some View {
        content
            .environment(valutaConversion)
    }
}
