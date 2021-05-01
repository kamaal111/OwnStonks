//
//  HomeGridView.swift
//  OwnStonks
//
//  Created by Kamaal Farah on 01/05/2021.
//

import SwiftUI

struct HomeGridView: View {
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
            pinnedViews: []) {
            Section(header: HomeHeaderView(viewWidth: viewWidth, columns: columns.count)) {
                ForEach(data, id: \.self) { stonk in
                    Text(stonk.name)
                    Text("\(stonk.shares)")
                    Text(String(format: "€%.2f", stonk.currentPrice))
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

struct HomeGridView_Previews: PreviewProvider {
    static var previews: some View {
        HomeGridView(data: [], viewWidth: 240)
    }
}
