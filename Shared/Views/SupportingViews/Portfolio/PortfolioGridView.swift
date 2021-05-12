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

    init(multiDimensionedData: [[StonkGridCellData]], viewWidth: CGFloat) {
        self.data = multiDimensionedData
        self.viewWidth = viewWidth
    }

    var body: some View {
        StonkGridView(
            headerTitles: Self.headerTitles,
            data: data,
            viewWidth: viewWidth,
            isPressable: false)
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
