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
import ConsoleSwift

struct TransactionSheet: View {
    @EnvironmentObject
    private var userData: UserData

    @ObservedObject
    private var viewModel: ViewModel

    let transaction: CoreTransaction?
    let close: () -> Void
    let delete: () -> Void
    let editTransaction: (_ id: UUID, _ args: CoreTransaction.Args) -> Void

    init(
        transaction: CoreTransaction?,
        close: @escaping () -> Void,
        delete: @escaping () -> Void,
        editTransaction: @escaping (_ id: UUID, _ args: CoreTransaction.Args) -> Void) {
        self.transaction = transaction
        self.close = close
        self.delete = delete
        self.editTransaction = editTransaction
        self.viewModel = ViewModel(transaction: transaction)
    }

    var body: some View {
        SheetStack(
            title: .TRANSACTION,
            leadingNavigationButton: { NavigationButton(
                title: viewModel.editMode ? .DONE : .EDIT,
                action: {
                    viewModel.onEditPress(editTransaction: editTransaction)
                }) },
            trailingNavigationButton: { NavigationButton(
                title: .CLOSE,
                action: close) }) {
            VStack {
                if let transactionCreationDate = transaction?.createdDate {
                    HStack {
                        Text(
                            localized: .CREATED_DATE,
                            with: Self.creationDateFormatter.string(from: transactionCreationDate))
                            .foregroundColor(.secondary)
                            .font(.callout)
                        Spacer()
                    }
                }
                if !viewModel.editMode {
                    if let transaction = self.transaction {
                        TransactionSheetRow(title: .INVESTMENT_LABEL, value: transaction.name)
                        if let transactionSymbol = transaction.symbol {
                            TransactionSheetRow(title: .SYMBOL, value: transactionSymbol)
                        }
                        TransactionSheetRow(
                            title: .COST_SHARE_HEADER_TITLE,
                            value: userData.moneyString(from: transaction.costPerShare))
                        TransactionSheetRow(title: .SHARES_LABEL, value: "\(transaction.shares)")
                        TransactionSheetRow(
                            title: .TRANSACTION_DATE_LABEL,
                            value: Self.tranactionDateFormatter.string(from: transaction.transactionDate))
                    }
                } else {
                    EditTransactionFields(
                        investment: $viewModel.editedInvestment,
                        costPerShare: $viewModel.editedCostPerShare,
                        shares: $viewModel.editedShares,
                        transactionDate: $viewModel.editedTransactionDate,
                        symbol: $viewModel.editedSymbol,
                        currency: userData.currency,
                        getActualPrice: {
                        if #available(macOS 12.0, *) {
                            await viewModel.getActualPrice()
                        } else {
                            console.log(Date(), "async await is not supported")
                        }
                    })
                    Button(action: delete) {
                        Text(localized: .DELETE)
                    }
                }
            }
            .padding(.vertical, 16)
        }
        .frame(minWidth: 360, minHeight: viewMinHeight)
        .alert(isPresented: $viewModel.showAlert) {
            Alert(title: Text(viewModel.alertMessage?.title ?? ""),
                  message: Text(viewModel.alertMessage?.message ?? ""),
                  dismissButton: .default(Text(localized: .OK)))
        }
    }

    private var viewMinHeight: CGFloat {
        if viewModel.editMode {
            return 328
        }
        let includingSymbolHeight: CGFloat = transaction?.symbol != nil ? 32 : 0
        return 248 + includingSymbolHeight
    }

    private static let tranactionDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }()

    private static let creationDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()

}

// - TODO: Put this in a seperate file
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
        HStack(alignment: .top) {
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
                TransactionSheet(
                    transaction: transaction,
                    close: { },
                    delete: { },
                    editTransaction: { _, _  in })
            })
            .environmentObject(UserData())
    }
 }
