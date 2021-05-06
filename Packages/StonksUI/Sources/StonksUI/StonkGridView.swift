//
//  StonkGridView.swift
//  
//
//  Created by Kamaal Farah on 06/05/2021.
//

import SwiftUI

@available(macOS 11.0, *)
public struct StonkGridView<Content: StonkGridCellRenderable>: View {
    public let headerTitles: [String]
    public let data: [[Content]]
    public let viewWidth: CGFloat

    public init(headerTitles: [String], data: [[Content]], viewWidth: CGFloat) {
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
                    ForEach(row) { item in
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

public protocol StonkGridCellRenderable: Hashable, Identifiable {
    var content: String { get }
}

private struct StonksGridItem<Content: StonkGridCellRenderable>: View {
    let text: Content
    let horizontalPadding: CGFloat

    init(text: Content, horizontalPadding: CGFloat = 16) {
        self.text = text
        self.horizontalPadding = horizontalPadding
    }
    var body: some View {
        Text(text.content)
            .frame(maxWidth: .infinity, alignment: .leading)
            .multilineTextAlignment(.leading)
            .padding(.horizontal, horizontalPadding)
    }
}

#if DEBUG
private struct StonkGridRenderItem: StonkGridCellRenderable {
    let id: Int
    let content: String
}

@available(macOS 11.0, *)
struct StonkGridView_Previews: PreviewProvider {
    static var previews: some View {
        StonkGridView(headerTitles: [], data: [] as [[StonkGridRenderItem]], viewWidth: 360)
    }
}
#endif
