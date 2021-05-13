//
//  AddTransactionScreen.swift
//  OwnStonks
//
//  Created by Kamaal M Farah on 01/05/2021.
//  Copyright © 2021 Kamaal Farah. All rights reserved.
//

import SwiftUI
import StonksUI
import StonksLocale

struct AddTransactionScreen: View {
    @Environment(\.presentationMode)
    private var presentationMode: Binding<PresentationMode>

    @EnvironmentObject
    private var stonksManager: StonksManager
    @EnvironmentObject
    private var userData: UserData
    #if canImport(AppKit)
    @EnvironmentObject
    private var navigator: Navigator
    #endif

    @ObservedObject
    private var viewModel = ViewModel()

    var body: some View {
        #if canImport(UIKit)
        view()
            .navigationBarTitle(Text(localized: .ADD_TRANSACTION_SCREEN_TITLE), displayMode: .inline)
            .navigationBarItems(trailing: saveButton())
        #else
        view()
            .toolbar(content: saveButton)
            .navigationTitle(Text(localized: .ADD_TRANSACTION_SCREEN_TITLE))
        #endif
    }

    private func view() -> some View {
        VStack {
            EditTransactionFields(
                investment: $viewModel.investment,
                costPerShare: $viewModel.costPerShare,
                shares: $viewModel.shares,
                transactionDate: $viewModel.transactionDate,
                currency: userData.currency)
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .padding(.vertical, 12)
        .padding(.horizontal, 24)
        .alert(isPresented: $viewModel.showAlert) {
            Alert(title: Text(viewModel.alertMessage?.title ?? ""),
                  message: Text(viewModel.alertMessage?.message ?? ""),
                  dismissButton: .default(Text(localized: .OK)))
        }
    }

    private func saveButton() -> some View {
        Button(action: saveAction) {
            Text(localized: .SAVE)
        }
    }

    private func saveAction() {
        let stonkResult = stonksManager.setTransaction(with: viewModel.transactionArgs)
        guard viewModel.saveAction(stonkResult: stonkResult) else { return }
        #if canImport(UIKit)
        presentationMode.wrappedValue.dismiss()
        #else
        navigator.navigate(to: nil)
        #endif
    }
}

struct AddTransactionScreen_Previews: PreviewProvider {
    static var previews: some View {
        AddTransactionScreen()
            .environmentObject(StonksManager(preview: true))
            .environmentObject(Navigator())
            .environmentObject(UserData())
    }
}
