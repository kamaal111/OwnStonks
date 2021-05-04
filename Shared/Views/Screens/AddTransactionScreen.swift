//
//  AddTransactionScreen.swift
//  OwnStonks
//
//  Created by Kamaal M Farah on 01/05/2021.
//

import SwiftUI
import StonksUI

struct AddTransactionScreen: View {
    @EnvironmentObject
    private var stonksManager: StonksManager
    @EnvironmentObject
    private var navigator: Navigator

    @ObservedObject
    private var viewModel = ViewModel()

    var body: some View {
        #if canImport(UIKit)
        view()
            .navigationBarTitle(Text("Add Transaction"), displayMode: .inline)
            .navigationBarItems(trailing: saveButton())
        #else
        view()
            .toolbar(content: saveButton)
            .navigationTitle(Text("Add Transaction"))
        #endif
    }

    private func view() -> some View {
        VStack {
            FloatingTextField(text: $viewModel.investment, title: "Investment")
            EnforcedFloatingDecimalField(value: $viewModel.costs, title: "Costs")
            EnforcedFloatingDecimalField(value: $viewModel.shares, title: "Shares")
            FloatingDatePicker(value: $viewModel.transactionDate, title: "Transaction date")
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .padding(.vertical, 12)
        .padding(.horizontal, 24)
        .alert(isPresented: $viewModel.showAlert) {
            Alert(title: Text(viewModel.alertMessage?.title ?? ""),
                  message: Text(viewModel.alertMessage?.message ?? ""),
                  dismissButton: .default(Text("OK")))
        }
    }

    private func saveButton() -> some View {
        Button(action: saveAction) {
            Text("Save")
        }
    }

    private func saveAction() {
        let stonkResult = stonksManager.setStonk(with: viewModel.stonkArgs)
        guard viewModel.saveAction(stonkResult: stonkResult) else { return }
        navigator.navigateToPortfolio()
    }
}

struct AddTransactionScreen_Previews: PreviewProvider {
    static var previews: some View {
        AddTransactionScreen()
            .environmentObject(StonksManager())
            .environmentObject(Navigator())
    }
}
