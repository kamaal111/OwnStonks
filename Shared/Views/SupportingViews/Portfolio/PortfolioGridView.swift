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
        StonkGridView(headerTitles: [
            "Name",
            "Shares",
            "Total Price"
        ], data: data, viewWidth: viewWidth)
    }
}

struct PortfolioGridView_Previews: PreviewProvider {
    static var previews: some View {
        PortfolioGridView(multiDimensionedData: [], viewWidth: 240)
    }
}
