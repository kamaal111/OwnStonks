//
//  TransactionsScreen.swift
//
//
//  Created by Kamaal M Farah on 25/11/2023.
//

import SwiftUI
import KamaalUI

public struct TransactionsScreen: View {
    @State private var viewModel = ViewModel()

    public init() { }

    public var body: some View {
        VStack {
            Text("Hello, World!")
        }
        .frame(minWidth: 320, minHeight: 348)
        .toolbar {
            #if os(iOS)
            ToolbarItem(placement: .topBarTrailing) { toolbarItem }
            #else
            toolbarItem
            #endif
        }
        .sheet(isPresented: $viewModel.showSheet) { presentedSheet }
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
                    onDone: viewModel.onModifyTransactionDone
                )
            case .none: EmptyView()
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

        func onModifyTransactionDone() { }

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
