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
                    Text(transaction.name)
                }
            }
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
            case .addTransction: ModifyTransactionSheet(
                    isShown: $viewModel.showSheet,
                    context: .new,
                    onDone: onModifyTransactionDone
                )
            case .none: EmptyView()
            }
        }
    }

    private func onModifyTransactionDone(_ transaction: AppTransaction) {
        transactionManager.createTransaction(transaction)
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

        private(set) var shownSheet: Sheets? {
            didSet { shownSheetDidSet() }
        }

        func showAddTransactionSheet() {
            shownSheet = .addTransction
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

    enum Sheets {
        case addTransction
    }
}

#Preview {
    TransactionsScreen()
}
