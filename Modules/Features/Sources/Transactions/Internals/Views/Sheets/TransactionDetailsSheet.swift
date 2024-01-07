//
//  TransactionDetailsSheet.swift
//
//
//  Created by Kamaal M Farah on 25/11/2023.
//

import SwiftUI
import SharedUI
import KamaalUI
import ForexKit
import SharedModels
import ValutaConversion

enum TransactionDetailsSheetContext: Equatable {
    case new(_ preferredCurrency: Currencies)
    case details(_ transaction: AppTransaction)
    case edit(_ transaction: AppTransaction)
}

struct TransactionDetailsSheet: View {
    @Environment(ValutaConversion.self) private var valutaConversion

    @State private var viewModel: ViewModel

    @Binding var isShown: Bool

    let isNotPendingInTheCloud: Bool
    let onDone: (_ transaction: AppTransaction) -> Void
    let onDelete: () -> Void

    init(
        isShown: Binding<Bool>,
        context: TransactionDetailsSheetContext,
        isNotPendingInTheCloud: Bool,
        onDone: @escaping (_: AppTransaction) -> Void,
        onDelete: @escaping () -> Void = { }
    ) {
        self._isShown = isShown
        self._viewModel = State(initialValue: ViewModel(context: context))
        self.isNotPendingInTheCloud = isNotPendingInTheCloud
        self.onDone = onDone
        self.onDelete = onDelete
    }

    var body: some View {
        KSheetStack(
            title: viewModel.title,
            leadingNavigationButton: { navigationButton(label: "Close", action: close) },
            trailingNavigationButton: {
                KJustStack {
                    if !isNotPendingInTheCloud {
                        Text("")
                    } else if viewModel.isEditing {
                        navigationButton(label: "Done", action: handleDone)
                            .disabled(!viewModel.transactionIsValid)
                    } else {
                        navigationButton(label: "Edit", action: { viewModel.enableEditing() })
                    }
                }
            }
        ) {
            VStack(alignment: .leading) {
                EditableText(
                    text: $viewModel.name,
                    label: NSLocalizedString("Name", bundle: .module, comment: ""),
                    isEditing: viewModel.isEditing,
                    textCase: .none
                )
                EditableDate(
                    date: $viewModel.transactionDate,
                    label: NSLocalizedString("Transaction Date", bundle: .module, comment: ""),
                    isEditing: viewModel.isEditing
                )
                .padding(.top, viewModel.isEditing ? .nada : .extraExtraSmall)
                EditablePicker(
                    selection: $viewModel.transactionType,
                    label: NSLocalizedString("Type", bundle: .module, comment: ""),
                    isEditing: viewModel.isEditing,
                    items: TransactionTypes.allCases,
                    valueColor: viewModel.transactionType.color
                ) { item in
                    Text(item.localized)
                }
                .padding(.top, viewModel.isEditing ? .nada : .extraExtraSmall)
                EditableDecimalText(
                    text: $viewModel.amount,
                    label: NSLocalizedString("Amount", bundle: .module, comment: ""),
                    isEditing: viewModel.isEditing
                )
                .padding(.top, viewModel.isEditing ? .nada : .extraExtraSmall)
                HStack {
                    EditableMoney(
                        currency: $viewModel.pricePerUnitCurrency,
                        value: $viewModel.pricePerUnit,
                        label: NSLocalizedString("Price per unit", bundle: .module, comment: ""),
                        isEditing: viewModel.isEditing
                    )
                    if viewModel.autoTrackAsset, viewModel.isEditing, viewModel.transactionIsValid {
                        Button(action: {
                            Task { await viewModel.fetchPricePerUnit(valutaConversion: valutaConversion) }
                        }, label: {
                            Image(systemName: "arrow.triangle.2.circlepath")
                                .kBold()
                                .foregroundColor(.accentColor)
                        })
                        .buttonStyle(.plain)
                    }
                }
                .padding(.top, viewModel.isEditing ? .nada : .extraExtraSmall)
                EditableMoney(
                    currency: $viewModel.feesCurrency,
                    value: $viewModel.fees,
                    label: NSLocalizedString("Fees", bundle: .module, comment: ""),
                    isEditing: viewModel.isEditing
                )
                .padding(.top, viewModel.isEditing ? .nada : .extraExtraSmall)
                CollapsableSection(title: NSLocalizedString("Auto tracking", bundle: .module, comment: "")) {
                    Toggle(isOn: $viewModel.autoTrackAsset, label: {
                        Text("Auto track asset")
                    })
                    .disabled(!viewModel.isEditing)
                    if viewModel.autoTrackAsset {
                        EditableText(
                            text: $viewModel.assetTicker,
                            label: NSLocalizedString("Ticker", bundle: .module, comment: ""),
                            isEditing: viewModel.isEditing,
                            textCase: .none
                        )
                        .padding(.top, viewModel.isEditing ? .nada : .extraExtraSmall)
                        EditablePicker(
                            selection: $viewModel.assetDataSource,
                            label: NSLocalizedString("Asset type", bundle: .module, comment: ""),
                            isEditing: viewModel.isEditing,
                            items: AssetDataSources.allCases
                        ) { item in
                            Text(item.localized)
                        }
                        .padding(.top, viewModel.isEditing ? .nada : .extraExtraSmall)
                    }
                }
                .padding(.top, .small)
                if !viewModel.isEditing, viewModel.transaction?.dataSource != nil {
                    StonksPerformanceChart()
                }
                if viewModel.isEditing, !viewModel.isNew {
                    Button(action: handleDelete) {
                        HStack {
                            Image(systemName: "trash.fill")
                            Text("Delete this transaction", bundle: .module)
                        }
                        .foregroundColor(.red)
                    }
                    .padding(.top, .small)
                    .ktakeWidthEagerly(alignment: .center)
                }
            }
            .padding(.vertical, .medium)
        }
        .padding(.vertical, .medium)
        .alert(viewModel.errorAlertTitle, isPresented: $viewModel.showErrorAlert, actions: {
            Button(role: .cancel, action: { }) {
                Text("OK", bundle: .module)
            }
        })
        .disabled(viewModel.loading)
        .onAppear(perform: { Task { await viewModel.fetchCloses() } })
        #if os(macOS)
            .frame(minWidth: 320, minHeight: viewModel.isEditing ? 412 : 260)
        #endif
    }

    private func navigationButton(label: LocalizedStringKey, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label, bundle: .module)
                .bold()
                .foregroundStyle(.tint)
        }
    }

    private func handleDone() {
        Task {
            await viewModel.finalizeEditing(close: { close() }, done: { transaction in
                onDone(transaction)
            })
        }
    }

    func handleDelete() {
        close()
        // Delete is not triggered on iOS unless there is a small delay calling onDelete
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            onDelete()
        }
    }

    private func close() {
        isShown = false
    }
}

#Preview {
    TransactionDetailsSheet(
        isShown: .constant(true),
        context: .edit(.preview),
        isNotPendingInTheCloud: true,
        onDone: { _ in },
        onDelete: { }
    )
    .environment(ValutaConversion())
}
