//
//  TransactionView.swift
//  OwnStonks
//
//  Created by Kamaal M Farah on 30/12/2022.
//

import Models
import SwiftUI
import ZaWarudo

struct TransactionView: View {
    let transaction: OSTransaction

    var body: some View {
        Text(transaction.assetName)
    }
}

struct TransactionView_Previews: PreviewProvider {
    static var previews: some View {
        TransactionView(
            transaction: .init(
                assetName: "Bitcoin",
                date: Current.date(),
                type: .buy,
                amount: 1,
                pricePerUnit: .init(amount: 15_000, currency: .EUR),
                fees: .init(amount: 0, currency: .EUR)))
    }
}
