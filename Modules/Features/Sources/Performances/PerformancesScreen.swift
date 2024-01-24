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

    public init() { }

    public var body: some View {
        KScrollableForm {
            KSection(header: "Stuff") {
                ForEach(transactions) { transaction in
                    Text(transaction.name)
                }
            }
        }
        .fetchAndConvertTransactions($transactions)
    }
}

#Preview {
    PerformancesScreen()
}
