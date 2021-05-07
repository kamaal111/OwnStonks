//
//  Navigator.swift
//  OwnStonks
//
//  Created by Kamaal Farah on 29/04/2021.
//  Copyright © 2021 Kamaal Farah. All rights reserved.
//

import Combine
import SwiftUI
import StonksLocale

final class Navigator: ObservableObject {

    #if canImport(UIKit)
    @Published var showAddTransactionScreen = false
    @Published var tabSelection = ScreenNames.portfolio.rawValue {
        didSet {
            if showAddTransactionScreen {
                showAddTransactionScreen = false
            }
        }
    }
    #endif
    @Published var screenSelection: String?

    enum ScreenNames: String {
        case portfolio
        case addTransaction
        case transactions
    }

    static let screens: [ScreenModel] = [
        .init(key: .PORTFOLIO_SCREEN_TITLE, imageSystemName: "chart.pie.fill", screen: .portfolio),
        .init(key: .TRANSACTIONS_SCREEN_TITLE, imageSystemName: "arrow.up.arrow.down", screen: .transactions)
    ]

    func navigateToAddTransactionScreen() {
        DispatchQueue.main.async { [weak self] in
            #if canImport(AppKit)
            self?.screenSelection = ScreenNames.addTransaction.rawValue
            #else
            self?.showAddTransactionScreen = true
            #endif
        }
    }

    func navigateToPortfolio() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            #if canImport(UIKit)
            if self.showAddTransactionScreen {
                self.showAddTransactionScreen = false
            }
            #endif
            self.screenSelection = nil
        }
    }

}

struct ScreenModel: Hashable {
    let tag: String
    let name: String
    let imageSystemName: String
    let screen: Navigator.ScreenNames

    init(name: String, imageSystemName: String, screen: Navigator.ScreenNames) {
        self.name = name
        self.imageSystemName = imageSystemName
        self.screen = screen
        self.tag = screen.rawValue
    }

    init(key: StonksLocale.Keys, imageSystemName: String, screen: Navigator.ScreenNames) {
        self.name = key.localized
        self.imageSystemName = imageSystemName
        self.screen = screen
        self.tag = screen.rawValue
    }

    var view: some View {
        ZStack {
            switch screen {
            case .portfolio: PortfolioScreen()
            case .transactions: TransactionsScreen()
            default: EmptyView()
            }
        }
    }
}
