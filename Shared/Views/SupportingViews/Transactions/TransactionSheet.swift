//
//  TransactionSheet.swift
//  OwnStonks
//
//  Created by Kamaal Farah on 10/05/2021.
//  Copyright © 2021 Kamaal Farah. All rights reserved.
//

import SwiftUI
import StonksUI
import StonksLocale

struct TransactionSheet: View {
    @State private var editMode = false

    let transaction: CoreTransaction?
    let currency: String
    let close: () -> Void
    let delete: () -> Void

    var body: some View {
        SheetStack(
            /// - TODO: Localize this
            title: "Tranaction",
            leadingNavigationButton: { NavigationButton(
                /// - TODO: Localize this
                title: editMode ? "Done" : "Edit",
                action: onEditPress) },
            trailingNavigationButton: { NavigationButton(
                title: .CLOSE,
                action: close) }) {
            VStack {
                HStack {
                    /// - TODO: Localize this
                    Text("Created: \(Self.creationDateFormatter.string(from: Date()))")
                        .foregroundColor(.secondary)
                        .font(.callout)
                    Spacer()
                }
                if let transaction = self.transaction {
                    TransactionSheetRow(title: .INVESTMENT_LABEL, value: transaction.name)
                    TransactionSheetRow(
                        title: .COST_SHARE_HEADER_TITLE,
                        value: "\(currency)\(transaction.costPerShare.toFixed(2))")
                    TransactionSheetRow(title: .SHARES_LABEL, value: "\(transaction.shares)")
                    TransactionSheetRow(
                        title: .TRANSACTION_DATE_LABEL,
                        value: Self.tranactionDateFormatter.string(from: transaction.transactionDate))
                    if editMode {
                        Button(action: delete) {
                            /// - TODO: Localize this
                            Text("Delete")
                        }
                    }
                }
            }
            .padding(.vertical, 16)
        }
        .frame(minWidth: 360, minHeight: editMode ? 272 : 248)
    }

    private func onEditPress() {
        if editMode {
            withAnimation { editMode = false }
        } else {
            withAnimation { editMode = true }
        }
    }

    static let tranactionDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }()

    static let creationDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()

}

private struct TransactionSheetRow: View {
    let title: String
    let value: String

    init(title: String, value: String) {
        self.title = title
        self.value = value
    }

    init(title: StonksLocale.Keys, value: String) {
        self.title = title.localized
        self.value = value
    }

    var body: some View {
        HStack {
            Text(title)
                .bold()
                .frame(width: 100, alignment: .leading)
            Text(value)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 4)
    }
}

 struct TransactionSheet_Previews: PreviewProvider {
    static var previews: some View {
        let transaction: CoreTransaction?
        do {
            transaction = try PersistenceController.preview.fetch(CoreTransaction.self).get()?.first
        } catch {
            fatalError("Could not find transaction")
        }
        return Text("Hallo")
            .sheet(isPresented: .constant(true), content: {
                TransactionSheet(transaction: transaction, currency: "$", close: { }, delete: { })
        })
    }
 }
