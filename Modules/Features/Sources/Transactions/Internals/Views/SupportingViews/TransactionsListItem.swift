//
//  TransactionsListItem.swift
//
//
//  Created by Kamaal M Farah on 10/12/2023.
//

import SwiftUI
import SharedUI
import KamaalUI

struct TransactionsListItem: View {
    let transaction: AppTransaction
    let layout: TransactionsListLayouts
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

    var localizedStringKey: String {
        switch self {
        case .transactionDate: "Transaction Date"
        case .amount: "Amount"
        case .pricePerUnit: "Price per unit"
        case .fees: "Fees"
        }
    }
}

#Preview {
    TransactionsListItem(transaction: .preview, layout: .large, action: { }, onDelete: { }, onEdit: { })
}
