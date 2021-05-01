//
//  PortfolioGridView.swift
//  OwnStonks
//
//  Created by Kamaal Farah on 01/05/2021.
//

import SwiftUI
import ShrimpExtensions

struct PortfolioGridView: View {
    let data: [StonksData]
    let viewWidth: CGFloat

    init(data: [StonksData], viewWidth: CGFloat) {
        self.data = data
        self.viewWidth = viewWidth
    }

    var body: some View {
        LazyVGrid(
            columns: columns,
            alignment: .center,
            spacing: 8,
            pinnedViews: [.sectionHeaders]) {
            Section(header: PortfolioHeaderView(viewWidth: viewWidth, headerTitles: [
                "Name",
                "Shares",
                "Price"
            ])) {
                ForEach(data, id: \.self) { stonk in
                    PortfolioGridItem(text: stonk.name)
                    PortfolioGridItem(text: "\(stonk.shares)")
                    PortfolioGridItem(text: stonk.currentPrice.toFixed(2))
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
