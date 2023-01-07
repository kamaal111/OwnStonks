//
//  TransactionDetailSheet.swift
//  OwnStonks
//
//  Created by Kamaal M Farah on 29/12/2022.
//

import Models
import Logster
import SwiftUI
import SalmonUI
import PopperUp
import ZaWarudo
import OSLocales
import ShrimpExtensions

private let logger = Logster(from: TransactionDetailSheet.self)

struct TransactionDetailSheet: View {
    @StateObject private var viewModel: ViewModel

    @Binding var isShown: Bool

    let context: TransactionDetailSheetContext
    let submittedTransactions: (_ transaction: [OSTransaction]) -> Void

    init(
        isShown: Binding<Bool>,
        context: TransactionDetailSheetContext,
        submittedTransactions: @escaping (_ transaction: [OSTransaction]) -> Void) {
            self._isShown = isShown
            self.context = context
            self.submittedTransactions = submittedTransactions
            self._viewModel = StateObject(wrappedValue: ViewModel(isEditing: context.isNew))
        }

    // - MARK: Views

    var body: some View {
        KSheetStack(
            title: title,
            leadingNavigationButton: { closeButton },
            trailingNavigationButton: { doneButton }) {
                content
            }
            .frame(minWidth: 320, minHeight: viewModel.isEditing ? 348 : 220)
            .onAppear(perform: handleOnAppear)
    }

    private var content: some View {
        VStack(spacing: 4) {
            if context.isNew {
                WideButton(action: { viewModel.importTransactionsFromFile() }) {
                    OSText(localized: .IMPORT)
                        .bold()
                }
            }
            EditableText(text: $viewModel.assetName, localized: .NAME, isEditing: viewModel.isEditing)
            EditableDate(date: $viewModel.transactionDate, localized: .TRANSACTION_DATE, isEditing: viewModel.isEditing)
            EditablePickerType(
                selection: $viewModel.transactionType,
                localized: .TYPE,
                items: TransactionTypes.allCases,
                isEditing: viewModel.isEditing) { item in
                    OSText(item.localized)
                }
            EditableDecimal(value: $viewModel.transactionAmount, localized: .AMOUNT, isEditing: viewModel.isEditing)
            EditableMoney(
                currency: $viewModel.pricePerUnitCurrency,
                value: $viewModel.pricePerUnit,
                localized: .PRICE_PER_UNIT,
                isEditing: viewModel.isEditing)
            EditableMoney(
                currency: $viewModel.feesCurrency,
                value: $viewModel.fees,
                localized: .FEES,
                isEditing: viewModel.isEditing)
        }
        .padding(.vertical, .medium)
        .openFile(isPresented: $viewModel.showOpenFileView, onFileOpen: handleOpenFile)
        .popperUpLite(
            isPresented: $viewModel.showErrorPopup,
            style: .bottom(
                title: OSLocales.getText(.DECODE_CSV_FAILURE_TITLE),
                type: .warning,
                description: OSLocales.getText(.DECODE_CSV_FAILURE_DESCRIPTION)),
            backgroundColor: Color("BackgroundColor"))
    }

    private var closeButton: some View {
        Button(action: onClose) {
            OSText(localized: .CLOSE)
                .foregroundColor(.accentColor)
        }
    }

    private var doneButton: some View {
        KJustStack {
            if viewModel.isEditing {
                Button(action: onDone) {
                    OSText(localized: .DONE)
                        .foregroundColor(.accentColor)
                }
                .disabled(viewModel.invalidTransaction)
            } else {
                Button(action: onEdit) {
                    OSText(localized: .EDIT)
                        .foregroundColor(.accentColor)
                }
            }
        }
    }

    private var title: String {
        switch context {
        case .addTransaction:
            return OSLocales.getText(.ADD_TRANSACTION)
        case .editTransaction(transaction: let transaction):
            return transaction.assetName
        }
    }

    // - MARK: Lifecycle handlers

    private func handleOpenFile(_ data: Data) {
        Task {
            let transactions = await viewModel.loadContentOfImportedFile(data)
            guard let transactions, !transactions.isEmpty else { return }

            submittedTransactions(transactions)
            onClose()
        }
    }

    private func handleOnAppear() {
        if case .editTransaction(let transaction) = context {
            viewModel.setValues(with: transaction)
        }
    }

    private func onClose() {
        isShown = false
    }

    private func onDone() {
        submittedTransactions([viewModel.transaction])
        onClose()
    }

    private func onEdit() {
        viewModel.toggleEditing()
    }
}

// - MARK: View Model

private final class ViewModel: ObservableObject {
    @Published var assetName = ""
    @Published var transactionDate = Current.date()
    @Published var transactionType: TransactionTypes = .buy
    @Published var transactionAmount = 0.0
    @Published var pricePerUnitCurrency: Currencies = .EUR
    @Published var pricePerUnit = 0.0
    @Published var feesCurrency: Currencies = .EUR
    @Published var fees = 0.0
    @Published private(set) var isEditing: Bool
    @Published var showOpenFileView = false
    @Published var showErrorPopup = false

    private var transactionID: UUID?
    private var errorPopupTimer: Timer?

    init(isEditing: Bool) {
        self.isEditing = isEditing
    }

    // - MARK: API

    var transaction: OSTransaction {
        .init(
            id: transactionID,
            assetName: assetName,
            date: transactionDate,
            type: transactionType,
            amount: transactionAmount,
            pricePerUnit: .init(amount: pricePerUnit, currency: pricePerUnitCurrency),
            fees: .init(amount: fees, currency: feesCurrency))
    }

    var invalidTransaction: Bool {
        assetName.trimmingByWhitespacesAndNewLines.isEmpty
    }

    @MainActor
    func importTransactionsFromFile() {
        showOpenFileView = true
    }

    @MainActor
    func toggleEditing() {
        withAnimation {
            isEditing.toggle()
        }
    }

    @MainActor
    func setValues(with transaction: OSTransaction) {
        transactionID = transaction.id
        assetName = transaction.assetName
        transactionDate = transaction.date
        transactionType = transaction.type
        transactionAmount = transaction.amount
        pricePerUnitCurrency = transaction.pricePerUnit.currency
        pricePerUnit = transaction.pricePerUnit.amount
        feesCurrency = transaction.fees.currency
        fees = transaction.fees.amount
        isEditing = false
    }

    func loadContentOfImportedFile(_ data: Data) async -> [OSTransaction]? {
        let transactions: [OSTransaction]
        do {
            transactions = try OSTransaction.fromCSV(data: data, seperator: ";")
        } catch {
            logger.warning("Failed to read contents of CSV; description='\(error.localizedDescription)'; error='\(error)")
            await openErrorPopup()
            return nil
        }

        return transactions
    }

    // - MARK: Privates

    @MainActor
    private func openErrorPopup() {
        guard !showErrorPopup else { return }

        showErrorPopup = true
        errorPopupTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: false, block: { [weak self] timer in
            self?.handleErrorPopupTimer(timer)
        })
    }

    private func handleErrorPopupTimer(_ timer: Timer) {
        errorPopupTimer?.invalidate()
        errorPopupTimer = nil
        Task { await closeErrorPopUp() }
    }

    @MainActor
    private func closeErrorPopUp() {
        showErrorPopup = false
    }
}

// - MARK: Preview

struct TransactionDetailSheet_Previews: PreviewProvider {
    static var previews: some View {
        TransactionDetailSheet(isShown: .constant(true), context: .addTransaction, submittedTransactions: { _ in })
    }
}
