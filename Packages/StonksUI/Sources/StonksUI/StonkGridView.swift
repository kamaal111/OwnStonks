//
//  StonkGridView.swift
//  
//
//  Created by Kamaal Farah on 06/05/2021.
//

import SwiftUI

@available(macOS 11.0, *)
public struct StonkGridView: View {
    public let headerTitles: [String]
    public let data: [[String]]
    public let viewWidth: CGFloat

    public init(headerTitles: [String], data: [[String]], viewWidth: CGFloat) {
        self.headerTitles = headerTitles
        self.data = data
        self.viewWidth = viewWidth
    }

    public var body: some View {
        LazyVGrid(
            columns: columns,
            alignment: .center,
            spacing: 8,
            pinnedViews: [.sectionHeaders]) {
            Section(header: GridHeaderView(viewWidth: viewWidth, headerTitles: headerTitles)) {
                ForEach(data, id: \.self) { row in
                    ForEach(row, id: \.self) { item in
                        StonksGridItem(text: item)
                    }
                }
            }
        }
    }

    private var columns: [GridItem] {
        headerTitles.map { _ in
            GridItem(.flexible())
        }
    }
}

private struct StonksGridItem: View {
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

@available(macOS 11.0, *)
struct StonkGridView_Previews: PreviewProvider {
    static var previews: some View {
        StonkGridView(headerTitles: [], data: [], viewWidth: 360)
    }
}
