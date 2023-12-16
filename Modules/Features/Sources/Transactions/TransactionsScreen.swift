//
//  TransactionsScreen.swift
//
//
//  Created by Kamaal M Farah on 25/11/2023.
//

import SwiftUI
import KamaalUI
import KamaalPopUp
import UserSettings

public struct TransactionsScreen: View {
    @Environment(TransactionsManager.self) private var transactionManager
    @Environment(UserSettings.self) private var userSettings
    @EnvironmentObject private var popUpManager: KPopUpManager

    @State private var viewModel = ViewModel()

    public init() { }

    public var body: some View {
        KScrollableForm {
            KSection(header: NSLocalizedString("Transactions", bundle: .module, comment: "")) {
                if transactionManager.loading {
                    KLoading()
                } else if transactionManager.transactionsAreEmpty {
                    AddFirstTransactionButton(action: { viewModel.showAddTransactionSheet() })
                }
                TransactionsList(
                    transactions: transactionManager.transactions,
                    layout: viewModel.transactionsSectionSize.width < 500 ? .medium : .large,
                    transactionAction: { transaction in viewModel.handleTransactionPress(transaction) }
                )
            }
            .kBindToFrameSize($viewModel.transactionsSectionSize)
            #if os(macOS)
                .padding(.horizontal, .medium)
            #endif
        }
        .padding(.vertical, .medium)
        .toolbar {
            #if os(iOS)
            ToolbarItem(placement: .topBarTrailing) { toolbarItem }
            #else
            toolbarItem
            #endif
        }
        .sheet(isPresented: $viewModel.showSheet) { presentedSheet }
        .onAppear(perform: handleOnAppear)
    }

    private var toolbarItem: some View {
        Button(action: { viewModel.showAddTransactionSheet() }) {
            Image(systemName: "plus")
                .bold()
                .foregroundStyle(.tint)
                .accessibilityHint(NSLocalizedString("Open new transaction sheet", bundle: .module, comment: ""))
                .accessibilityLabel(Text("Add Transaction", bundle: .module))
        }
    }

    private var presentedSheet: some View {
        KJustStack {
            switch viewModel.shownSheet {
            case .addTransction:
                TransactionDetailsSheet(
                    isShown: $viewModel.showSheet,
                    context: .new(userSettings.preferredForexCurrency),
                    onDone: onModifyTransactionDone
                )
            case let .transactionDetails(transaction):
                TransactionDetailsSheet(
                    isShown: $viewModel.showSheet,
                    context: .details(transaction),
                    onDone: onModifyTransactionDone
                )
            case .none: EmptyView()
            }
        }
    }

    private func onModifyTransactionDone(_ transaction: AppTransaction) {
        switch viewModel.shownSheet {
        case .addTransction: transactionManager.createTransaction(transaction)
        case .transactionDetails:
            do {
                try transactionManager.editTransaction(transaction)
            } catch {
                popUpManager.showPopUp(
                    style: .bottom(
                        title: NSLocalizedString("Failed to update transaction", bundle: .module, comment: ""),
                        type: .error,
                        description: nil
                    ),
                    timeout: 5
                )
            }
        case .none: assertionFailure("Should not be here!")
        }
    }

    private func handleOnAppear() {
        Task {
            do {
                try await transactionManager.fetchTransactions()
            } catch {
                popUpManager.showPopUp(
                    style: .bottom(
                        title: NSLocalizedString("Failed to get transactions", bundle: .module, comment: ""),
                        type: .error,
                        description: nil
                    ),
                    timeout: 5
                )
            }
        }
    }
}

extension TransactionsScreen {
    @Observable
    final class ViewModel {
        var showSheet = false {
            didSet { showSheetDidSet() }
        }

        var transactionsSectionSize: CGSize = .zero

        private(set) var shownSheet: Sheets? {
            didSet { shownSheetDidSet() }
        }

        func showAddTransactionSheet() {
            shownSheet = .addTransction
        }

        func handleTransactionPress(_ transaction: AppTransaction) {
            shownSheet = .transactionDetails(transaction)
        }

        private func shownSheetDidSet() {
            if shownSheet == nil, showSheet {
                showSheet = false
            } else if shownSheet != nil, !showSheet {
                showSheet = true
            }
        }

        private func showSheetDidSet() {
            if !showSheet, shownSheet != nil {
                shownSheet = nil
            }
        }
    }

    enum Sheets: Equatable {
        case addTransction
        case transactionDetails(_ transaction: AppTransaction)
    }
}

#Preview {
    TransactionsScreen()
}
