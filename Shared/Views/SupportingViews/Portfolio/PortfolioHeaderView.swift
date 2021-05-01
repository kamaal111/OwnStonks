//
//  PortfolioHeaderView.swift
//  OwnStonks
//
//  Created by Kamaal Farah on 01/05/2021.
//

import SwiftUI

struct PortfolioHeaderView: View {
    let viewWidth: CGFloat
    let horizontalPadding: CGFloat
    let headerTitles: [String]

    init(viewWidth: CGFloat, headerTitles: [String], horizontalPadding: CGFloat = 8) {
        self.viewWidth = viewWidth
        self.headerTitles = headerTitles
        self.horizontalPadding = horizontalPadding
    }

    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<headerTitles.count) { colIdx in
                Text(headerTitles[colIdx])
                    .font(.headline)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 8)
                    .frame(width: headerWidth, alignment: .leading)
                    .background(Color(.textBackgroundColor))
                    .padding(.horizontal, horizontalPadding)
            }
        }
    }

    private var headerWidth: CGFloat {
        guard viewWidth > 0 else { return 0 }
        return (viewWidth / CGFloat(headerTitles.count)) - (horizontalPadding * 2)
    }
}

struct PortfolioHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        PortfolioHeaderView(viewWidth: 80, headerTitles: [
            "Name",
            "Shares",
            "Price"
        ])
    }
}
