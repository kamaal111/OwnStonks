//
//  TransactionsEnvironmentModifier.swift
//
//
//  Created by Kamaal M Farah on 10/12/2023.
//

import SwiftUI

extension View {
    /// The environment view modifier that gives all the ``Transactions`` its context.
    /// - Returns: A modified view with the ``Transactions`` feature context.
    public func transactionEnvironment() -> some View {
        modifier(TransactionsEnvironmentModifier())
    }
}

private struct TransactionsEnvironmentModifier: ViewModifier {
    @State private var transactionsManager = TransactionsManager()

    func body(content: Content) -> some View {
        content
            .environment(transactionsManager)
    }
}
