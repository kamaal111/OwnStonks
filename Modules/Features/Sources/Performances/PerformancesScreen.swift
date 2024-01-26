//
//  PerformancesScreen.swift
//
//
//  Created by Kamaal M Farah on 21/01/2024.
//

import SwiftUI
import KamaalUI
import Transactions

public struct PerformancesScreen: View {
    @State private var transactions: [AppTransaction] = []
    @State private var loadingTransactions = false

    public init() { }

    public var body: some View {
        KScrollableForm {
            KSection(header: NSLocalizedString("Holdings", bundle: .module, comment: "")) {
                ForEach(transactions) { transaction in
                    Text(transaction.name)
                }
            }
        }
        .fetchAndConvertTransactions(transactions: $transactions, loading: $loadingTransactions)
    }
}

#Preview {
    PerformancesScreen()
}
