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
    let data: [CoreTransaction.Hasher]
    let viewWidth: CGFloat

    init(data: [CoreTransaction.Hasher], viewWidth: CGFloat) {
        self.data = data
        self.viewWidth = viewWidth
    }

    var body: some View {
        LazyVGrid(
            columns: columns,
            alignment: .center,
            spacing: 8,
            pinnedViews: [.sectionHeaders]) {
            Section(header: GridHeaderView(viewWidth: viewWidth, headerTitles: [
                "Name",
                "Shares",
                "Cost/Share"
            ])) {
                ForEach(data, id: \.self) { transaction in
                    PortfolioGridItem(text: transaction.name)
                    PortfolioGridItem(text: "\(transaction.shares)")
                    PortfolioGridItem(text: transaction.costPerShare.toFixed(2))
                }
            }
        }
    }

    private var columns: [GridItem] = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
}

struct PortfolioGridItem: View {
    let text: String
    let horizontalPadding: CGFloat

    init(text: String, horizontalPadding: CGFloat = 16) {
        self.text = text
        self.horizontalPadding = horizontalPadding
    }
    var body: some View {
        Text(text)
            .frame(maxWidth: .infinity, alignment: .leading)
            .multilineTextAlignment(.leading)
            .padding(.horizontal, horizontalPadding)
    }
}

struct PortfolioGridView_Previews: PreviewProvider {
    static var previews: some View {
        PortfolioGridView(data: [], viewWidth: 240)
    }
}
