//
//  TransactionsListItem.swift
//
//
//  Created by Kamaal M Farah on 10/12/2023.
//

import SwiftUI
import SharedUI
import KamaalUI
import SharedModels

struct TransactionsListItem: View {
    let transaction: AppTransaction
    let action: () -> Void
    let onDelete: () -> Void
    let onEdit: () -> Void

    var body: some View {
        Button(action: action) {
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
                VStack(alignment: .leading) {
                    informationLabel("Price", value: totalPrice)
                }
            }
            .ktakeWidthEagerly(alignment: .leading)
            .kInvisibleFill()
        }
        .buttonStyle(.plain)
        .contextMenu {
            KJustStack {
                Button(action: { onEdit() }) {
                    HStack {
                        Image(systemName: "pencil")
                        Text("Edit", bundle: .module)
                    }
                }
                Button(role: .destructive, action: { onDelete() }) {
                    HStack {
                        Image(systemName: "trash")
                        Text("Delete", bundle: .module)
                    }
                }
            }
        }
    }

    private func informationLabel(
        _ label: String,
        value: String,
        foregroundColor: Color = .primary
    ) -> some View {
        AppLabel(
            title: NSLocalizedString(label, bundle: .module, comment: ""),
            value: value,
            valueColor: foregroundColor
        )
    }

    private var totalPrice: String {
        let totalPriceExcludingFees = transaction.totalPriceExcludingFees
        let fees = transaction.fees
        if totalPriceExcludingFees.currency == fees.currency {
            let totalPriceValue = totalPriceExcludingFees.value + fees.value
            let totalPriceMoney = Money(value: totalPriceValue, currency: totalPriceExcludingFees.currency)
            return totalPriceMoney.localized
        }

        return "\(totalPriceExcludingFees.localized) + \(fees.localized)"
    }

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }()
}

#Preview {
    TransactionsListItem(transaction: .preview, action: { }, onDelete: { }, onEdit: { })
}
