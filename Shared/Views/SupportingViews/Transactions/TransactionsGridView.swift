//
//  TransactionsGridView.swift
//  OwnStonks
//
//  Created by Kamaal M Farah on 07/05/2021.
//  Copyright © 2021 Kamaal Farah. All rights reserved.
//

import SwiftUI
import StonksUI
import StonksLocale

struct TransactionsGridView: View {
    let data: [[StonkGridCellData]]
    let viewWidth: CGFloat

    init(multiDimensionedData: [[StonkGridCellData]], viewWidth: CGFloat) {
        self.viewWidth = viewWidth
        self.data = multiDimensionedData
    }

    var body: some View {
        StonkGridView(headerTitles: Self.headerTitles, data: data, viewWidth: viewWidth)
    }

    static let headerTitles: [String] = {
        let keys: [StonksLocale.Keys] = [
            .NAME_HEADER_TITLE,
            .SHARES_HEADER_TITLE,
            .COST_SHARE_HEADER_TITLE,
            .TOTAL_PRICE_HEADER_TITLE
        ]
        return keys.map(\.localized)
    }()
}

struct TransactionsGridView_Previews: PreviewProvider {
    static var previews: some View {
        TransactionsGridView(multiDimensionedData: [], viewWidth: 320)
            .environmentObject(UserData())
    }
}
