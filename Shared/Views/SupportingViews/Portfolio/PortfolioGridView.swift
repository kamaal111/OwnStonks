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
    let data: [[String]]
    let viewWidth: CGFloat

    init(tranactions: [PortfolioItem], viewWidth: CGFloat) {
        var multiDimensionedData: [[String]] = []
        for transaction in tranactions {
            let row = [
                transaction.name,
                "\(transaction.shares)",
                "€\(transaction.totalPrice.toFixed(2))"
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
            "Total Price"
        ], data: data, viewWidth: viewWidth)
    }
}

struct PortfolioGridView_Previews: PreviewProvider {
    static var previews: some View {
        PortfolioGridView(multiDimensionedData: [], viewWidth: 240)
    }
}
