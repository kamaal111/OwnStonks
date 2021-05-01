//
//  HomeHeaderView.swift
//  OwnStonks
//
//  Created by Kamaal Farah on 01/05/2021.
//

import SwiftUI

struct HomeHeaderView: View {
    let viewWidth: CGFloat
    let columns: Int
    let horizontalPadding: CGFloat

    init(viewWidth: CGFloat, columns: Int, horizontalPadding: CGFloat = 8) {
        self.viewWidth = viewWidth
        self.columns = columns
        self.horizontalPadding = horizontalPadding
    }

    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<columns) { colIdx in
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.7))
                    .frame(width: headerWidth)
                    .overlay(Text("Column \(colIdx + 1)"))
                    .padding(.horizontal, horizontalPadding)
            }
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .frame(height: 40)
    }

    private var headerWidth: CGFloat {
        guard viewWidth > 0 else { return 0 }
        return (viewWidth / CGFloat(columns)) - (horizontalPadding * 2)
    }
}

struct HomeHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        HomeHeaderView(viewWidth: 80, columns: 3)
    }
}
