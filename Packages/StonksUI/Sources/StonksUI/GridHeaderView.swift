//
//  GridHeaderView.swift
//  
//
//  Created by Kamaal M Farah on 02/05/2021.
//

import SwiftUI

public struct GridHeaderView: View {
    public let viewWidth: CGFloat
    public let horizontalPadding: CGFloat
    public let headerTitles: [String]

    public init(viewWidth: CGFloat, headerTitles: [String], horizontalPadding: CGFloat = 8) {
        self.viewWidth = viewWidth
        self.headerTitles = headerTitles
        self.horizontalPadding = horizontalPadding
    }

    public var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<headerTitles.count) { colIdx in
                Text(headerTitles[colIdx])
                    .font(.headline)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 8)
                    .frame(width: headerWidth, alignment: .leading)
                    .background(Color.StonkBackground)
                    .padding(.horizontal, horizontalPadding)
            }
        }
    }

    private var headerWidth: CGFloat {
        guard viewWidth > 0 else { return 0 }
        return (viewWidth / CGFloat(headerTitles.count)) - (horizontalPadding * 2)
    }
}

struct GridHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        GridHeaderView(viewWidth: 300, headerTitles: [
            "Name",
            "Shares",
            "Price"
        ])
    }
}
