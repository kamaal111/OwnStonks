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
    let previousClose: Money?
    let showMoney: Bool
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
                    informationLabel("Price", value: totalPriceLabel, foregroundColor: totalPriceColor)
                    if let profitLoss {
                        informationLabel("P/L", value: profitLoss, foregroundColor: profitLossColor)
                    }
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

    private var totalPriceColor: Color {
        if !showMoney {
            return .secondary
        }

        return .primary
    }

    private var totalPriceLabel: String {
        guard showMoney else { return "***" }

        let totalPriceExcludingFees = transaction.totalPriceExcludingFees
        let fees = transaction.fees
        if totalPriceExcludingFees.currency == fees.currency {
            let totalPriceValue = totalPriceExcludingFees.value + fees.value
            let totalPriceMoney = Money(value: totalPriceValue, currency: totalPriceExcludingFees.currency)
            return totalPriceMoney.localized
        }

        return "\(totalPriceExcludingFees.localized) + \(fees.localized)"
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

    private var profitLossColor: Color {
        guard let previousClose else {
            assertionFailure("Should have previous close already")
            return .gray
        }

        assert(previousClose.currency == transaction.pricePerUnit.currency)
        if transaction.pricePerUnit.value < previousClose.value {
            return .green
        }
        if transaction.pricePerUnit.value > previousClose.value {
            return .red
        }
        return .gray
    }

    private var profitLoss: String? {
        guard let previousClose else { return nil }
        guard previousClose.currency == transaction.pricePerUnit.currency else { return nil }

        let profitLoss = ((previousClose.value - transaction.pricePerUnit.value) / previousClose.value) * 100
        return "\(profitLoss.toFixed(2))%"
    }

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }()
}

#Preview {
    TransactionsListItem(
        transaction: .preview,
        previousClose: nil,
        showMoney: true,
        action: { },
        onDelete: { },
        onEdit: { }
    )
}
