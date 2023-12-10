//
//  TransactionsListItem.swift
//
//
//  Created by Kamaal M Farah on 10/12/2023.
//

import AppUI
import SwiftUI
import KamaalUI

enum TransactionsListItemLayouts {
    case medium
    case large
}

struct TransactionsListItem: View {
    let transaction: AppTransaction
    let layout: TransactionsListItemLayouts

    var body: some View {
        Button(action: { print("transaction", transaction) }) {
            HStack {
                VStack(alignment: .leading) {
                    Text(transaction.name)
                        .foregroundColor(.accentColor)
                    informationLabel(
                        "Type",
                        value: transaction.transactionType.localized,
                        foregroundColor: transaction.transactionType.color
                    )
                }
                .padding(.trailing, .medium)
                if layout == .medium {
                    VStack(alignment: .leading) {
                        ForEach(InformationDataKeys.allCases, id: \.self) { key in
                            informationLabel(key.localizedStringKey, value: informationData[key]!)
                        }
                    }
                } else {
                    VStack(alignment: .leading) {
                        ForEach([InformationDataKeys.transactionDate, InformationDataKeys.amount], id: \.self) { key in
                            informationLabel(key.localizedStringKey, value: informationData[key]!)
                        }
                    }
                    .padding(.trailing, .medium)
                    VStack(alignment: .leading) {
                        ForEach([InformationDataKeys.pricePerUnit, InformationDataKeys.fees], id: \.self) { key in
                            informationLabel(key.localizedStringKey, value: informationData[key]!)
                        }
                    }
                }
            }
            .ktakeWidthEagerly(alignment: .leading)
            .kInvisibleFill()
        }
        .buttonStyle(.plain)
    }

    private func informationLabel(
        _ label: LocalizedStringKey,
        value: String,
        foregroundColor: Color = .primary
    ) -> some View {
        HStack {
            (Text(label, bundle: .module) + Text(":"))
                .foregroundColor(.secondary)
            Text(value)
                .textCase(.lowercase)
                .foregroundColor(foregroundColor)
        }
    }

    private var informationData: [InformationDataKeys: String] {
        [
            .transactionDate: Self.dateFormatter.string(from: transaction.transactionDate),
            .amount: String(transaction.amount),
            .pricePerUnit: transaction.pricePerUnit.localized,
            .fees: transaction.fees.localized,
        ]
    }

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }()
}

private enum InformationDataKeys: CaseIterable {
    case transactionDate
    case amount
    case pricePerUnit
    case fees

    var localizedStringKey: LocalizedStringKey {
        switch self {
        case .transactionDate: "Transaction Date"
        case .amount: "Amount"
        case .pricePerUnit: "Price per unit"
        case .fees: "Fees"
        }
    }
}

#Preview {
    TransactionsListItem(
        transaction: AppTransaction(
            name: "Apple",
            transactionDate: Date(timeIntervalSince1970: 1_702_233_813),
            transactionType: .buy,
            amount: 25,
            pricePerUnit: Money(value: 100, currency: .USD),
            fees: Money(value: 1, currency: .EUR)
        ),
        layout: .large
    )
}
