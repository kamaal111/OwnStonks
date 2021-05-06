//
//  TransactionsScreen.swift
//  OwnStonks
//
//  Created by Kamaal Farah on 04/05/2021.
//  Copyright © 2021 Kamaal Farah. All rights reserved.
//

import SwiftUI
import StonksUI

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
                GeometryReader { (geometry: GeometryProxy) in
                    ScrollView {
                        TransactionsGridView(tranactions: stonksManager.transactions, viewWidth: geometry.size.width)
                    }
                }
            }
        }
    }
}

struct TransactionsGridView: View {
    let data: [[String]]
    let viewWidth: CGFloat

    init(tranactions: [CoreTransaction], viewWidth: CGFloat) {
        var multiDimensionedData: [[String]] = []
        for transaction in tranactions {
            let row = [
                transaction.name,
                "\(transaction.shares)",
                "€\(transaction.costPerShare.toFixed(2))"
            ]
            multiDimensionedData.append(row)
        }
        self.data = multiDimensionedData
        self.viewWidth = viewWidth
    }

    init(multiDimensionedData: [[String]], viewWidth: CGFloat) {
        self.data = multiDimensionedData
        self.viewWidth = viewWidth
    }

    var body: some View {
        StonkGridView(headerTitles: [
            "Name",
            "Shares",
            "Cost/Share"
        ], data: data, viewWidth: viewWidth)
    }
}

struct TransactionsScreen_Previews: PreviewProvider {
    static var previews: some View {
        TransactionsScreen()
            .environmentObject(Navigator())
            .environmentObject(StonksManager())
    }
}
