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
    @Published var tabSelection = ScreenNames.portfolio.rawValue
    #endif
    @Published var screenSelection: String?
    #if DEBUG
    @Published var showPlaygroundScreen = false
    #endif

    enum ScreenNames: String {
        case portfolio
        case addTransaction
        case transactions
    }

    static let screens: [ScreenModel] = [
        .init(key: .PORTFOLIO_SCREEN_TITLE, imageSystemName: "chart.pie.fill", screen: .portfolio),
        .init(key: .TRANSACTIONS_SCREEN_TITLE, imageSystemName: "arrow.up.arrow.down", screen: .transactions)
    ]

    #if canImport(AppKit)
    func navigate(to screen: ScreenNames?) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.screenSelection = screen?.rawValue
        }
    }
    #endif

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
