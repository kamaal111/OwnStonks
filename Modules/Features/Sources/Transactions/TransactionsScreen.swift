//
//  TransactionsScreen.swift
//
//
//  Created by Kamaal M Farah on 25/11/2023.
//

import SwiftUI
import KamaalUI
import KamaalPopUp

public struct TransactionsScreen: View {
    @Environment(TransactionsManager.self) private var transactionManager
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
                ForEach(transactionManager.transactions) { transaction in
                    TransactionsListItem(
                        transaction: transaction,
                        layout: viewModel.transactionsSectionSize.width < 500 ? .medium : .large,
                        action: { viewModel.handleTransactionPress(transaction) }
                    )
                    #if os(macOS)
                    if transactionManager.transactions.last != transaction {
                        Divider()
                    }
                    #endif
                }
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
        }
    }

    private var presentedSheet: some View {
        KJustStack {
            switch viewModel.shownSheet {
            case .addTransction:
                TransactionDetailsSheet(
                    isShown: $viewModel.showSheet,
                    context: .new,
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
        case .transactionDetails: transactionManager.editTransaction(transaction)
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
                        title: NSLocalizedString("Failed to get transctions", bundle: .module, comment: ""),
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
