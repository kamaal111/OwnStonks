//
//  Navigator.swift
//  OwnStonks
//
//  Created by Kamaal Farah on 29/04/2021.
//

import Combine
import SwiftUI

final class Navigator: ObservableObject {

    #if canImport(UIKit)
    @Published var screenSelection: String?
    #else
    @Published var screenSelection: String? = ScreenNames.portfolio.rawValue
    #endif

    enum ScreenNames: String {
        case portfolio
        case addTransaction
    }

    static let screens: [ScreenModel] = [
        .init(name: "Portfolio", imageSystemName: "chart.pie.fill", screen: .portfolio),
    ]

    #if canImport(AppKit)
    func navigateToAddTransactionScreen() {
        DispatchQueue.main.async { [weak self] in
            self?.screenSelection = ScreenNames.addTransaction.rawValue
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

    var view: some View {
        ZStack {
            switch screen {
            case .portfolio: PortfolioScreen()
            default: EmptyView()
            }
        }
    }
}
