//
//  PortfolioGridView.swift
//  OwnStonks
//
//  Created by Kamaal Farah on 01/05/2021.
//  Copyright © 2021 Kamaal Farah. All rights reserved.
//

import SwiftUI
import ShrimpExtensions
import StonksUI
import StonksLocale

struct PortfolioGridView: View {
    let data: [[StonkGridCellData]]
    let viewWidth: CGFloat

    init(tranactions: [PortfolioItem], viewWidth: CGFloat) {
        var multiDimensionedData: [[StonkGridCellData]] = []
        var counter = 0
        for transaction in tranactions {
            let row = [
                StonkGridCellData(id: counter, content: transaction.name),
                StonkGridCellData(id: counter + 1, content: "\(transaction.shares)"),
                /// - TODO: Put euro sign in some kind of helper method to make it easier to switch to different valutas
                StonkGridCellData(id: counter + 2, content: "€\(transaction.totalPrice.toFixed(2))")
            ]
            multiDimensionedData.append(row)
            counter += 3
        }
        self.data = multiDimensionedData
        self.viewWidth = viewWidth
    }

    init(multiDimensionedData: [[StonkGridCellData]], viewWidth: CGFloat) {
        self.data = multiDimensionedData
        self.viewWidth = viewWidth
    }

    var body: some View {
        StonkGridView(headerTitles: Self.headerTitles, data: data, viewWidth: viewWidth)
    }

    static let headerTitles: [String] = {
        let keys: [StonksLocale.Keys] = [
            .NAME_HEADER_TITLE,
            .SHARES_HEADER_TITLE,
            .TOTAL_PRICE_HEADER_TITLE
        ]
        return keys.map(\.localized)
    }()
}

struct PortfolioGridView_Previews: PreviewProvider {
    static var previews: some View {
        PortfolioGridView(multiDimensionedData: [], viewWidth: 240)
    }
}
