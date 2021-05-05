//
//  TransactionsScreen.swift
//  OwnStonks
//
//  Created by Kamaal Farah on 04/05/2021.
//  Copyright © 2021 Kamaal Farah. All rights reserved.
//

import SwiftUI

struct TransactionsScreen: View {
    @EnvironmentObject
    private var navigator: Navigator
    @EnvironmentObject
    private var stonksManager: StonksManager

    var body: some View {
        #if canImport(UIKit)
        view()
            .navigationBarTitle(Text("Transactions"))
            .navigationBarItems(trailing: Button(action: navigator.navigateToAddTransactionScreen) {
                Image(systemName: "plus").size(.squared(20))
            })
        #else
        view()
            .navigationTitle(Text("Transactions"))
            .toolbar(content: {
                Button(action: navigator.navigateToAddTransactionScreen) {
                    Label("Add transaction", systemImage: "plus")
                }
            })
        #endif
    }

    private func view() -> some View {
        ZStack {
            #if canImport(UIKit)
            NavigationLink(destination: AddTransactionScreen(), isActive: $navigator.showAddTransactionScreen) {
                EmptyView()
            }
            #endif
            Color.StonkBackground
            if stonksManager.portfolioStonks.isEmpty {
                Button(action: navigator.navigateToAddTransactionScreen) {
                    Text("Add your first transaction")
                        .font(.headline)
                }
            } else {
                Text("Hello, World!")
            }
        }
    }
}

struct TransactionsScreen_Previews: PreviewProvider {
    static var previews: some View {
        TransactionsScreen()
            .environmentObject(Navigator())
            .environmentObject(StonksManager())
    }
}
