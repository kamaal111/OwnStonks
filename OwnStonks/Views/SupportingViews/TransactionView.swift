//
//  TransactionView.swift
//  OwnStonks
//
//  Created by Kamaal M Farah on 30/12/2022.
//

import Models
import SwiftUI
import SalmonUI
import ZaWarudo
import OSLocales

struct TransactionView: View {
    @Environment(\.layoutDirection) private var layoutDirection: LayoutDirection

    let transaction: OSTransaction
    let action: (_ transaction: OSTransaction) -> Void

    var body: some View {
        OSButton(action: { action(transaction) }) {
            HStack {
                VStack(alignment: .leading) {
                    OSText(transaction.assetName)
                        .foregroundColor(.accentColor)
                    typeLabel
                }
                .padding(.trailing, .medium)
                VStack(alignment: .leading) {
                    TransactionInformationLabel(
                        title: .TRANSACTION_DATE_LABEL,
                        value: Self.dateFormatter.string(from: transaction.date))
                    TransactionInformationLabel(title: .AMOUNT_LABEL, value: String(transaction.amount))
                }
                .padding(.trailing, .medium)
                VStack(alignment: .leading) {
                    TransactionInformationLabel(title: .PER_UNIT_LABEL, value: transaction.pricePerUnit.localized)
                    TransactionInformationLabel(title: .FEES_LABEL, value: transaction.fees.localized)
                }
            }
            .ktakeWidthEagerly(alignment: .leading)
        }
    }

    private var typeLabel: some View {
        let label = OSText("\(OSLocales.getText(.TYPE)):")
        let typeView = OSText(transaction.type.localized)
            .textCase(.lowercase)
            .foregroundColor(transaction.type.color)

        return HStack {
            if layoutDirection == .leftToRight {
                label
                typeView
            } else {
                typeView
                label
            }
        }
    }

    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }()
}

struct TransactionView_Previews: PreviewProvider {
    static var previews: some View {
        TransactionView(
            transaction: .init(
                id: UUID(uuidString: "94f03193-bb95-4755-8fbb-979320601dc2")!,
                assetName: "Bitcoin",
                date: Current.date(),
                type: .buy,
                amount: 0.0001200,
                pricePerUnit: .init(amount: 15_000, currency: .EUR),
                fees: .init(amount: 0, currency: .EUR)),
            action: { _ in })
    }
}
