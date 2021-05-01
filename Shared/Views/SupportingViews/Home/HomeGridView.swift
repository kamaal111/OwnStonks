//
//  HomeGridView.swift
//  OwnStonks
//
//  Created by Kamaal Farah on 01/05/2021.
//

import SwiftUI

struct HomeGridView: View {
    let viewWidth: CGFloat

    init(viewWidth: CGFloat) {
        self.viewWidth = viewWidth
    }

    var body: some View {
        LazyVGrid(
            columns: columns,
            alignment: .center,
            spacing: 8,
            pinnedViews: []) {
            Section(header: HomeHeaderView(viewWidth: viewWidth, columns: columns.count)) {
                ForEach(0..<100, id: \.self) { num in
                    Text("\(num)")
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
        HomeGridView(viewWidth: 240)
    }
}
