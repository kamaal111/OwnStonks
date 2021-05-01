//
//  Navigator.swift
//  OwnStonks
//
//  Created by Kamaal Farah on 29/04/2021.
//

import Combine
import SwiftUI

final class Navigator: ObservableObject {

    @Published var screenSelection: Int?

    enum ScreenNames {
        case portfolio
    }

    static let screens: [ScreenModel] = [
        .init(tag: 0, name: "Portfolio", imageSystemName: "chart.pie.fill", screen: .portfolio)
    ]

}

struct ScreenModel: Hashable {
    let tag: Int
    let name: String
    let imageSystemName: String
    let screen: Navigator.ScreenNames

    var view: some View {
        ZStack {
            switch screen {
            case .portfolio: PortfolioScreen()
            }
        }
    }
}
