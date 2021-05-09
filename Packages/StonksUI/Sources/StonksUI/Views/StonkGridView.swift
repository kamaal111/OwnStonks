//
//  StonkGridView.swift
//  
//
//  Created by Kamaal Farah on 06/05/2021.
//

import SwiftUI

@available(macOS 11.0, iOS 14.0, *)
public struct StonkGridView<Content: StonkGridCellRenderable>: View {
    public let headerTitles: [String]
    public let data: [[Content]]
    public let viewWidth: CGFloat
    public let onCellPress: (_ content: Content) -> Void

    public init(
        headerTitles: [String],
        data: [[Content]],
        viewWidth: CGFloat,
        onCellPress: @escaping (_ content: Content) -> Void) {
        self.headerTitles = headerTitles
        self.data = data
        self.viewWidth = viewWidth
        self.onCellPress = onCellPress
    }

    public var body: some View {
        LazyVGrid(
            columns: columns,
            alignment: .center,
            spacing: 0,
            pinnedViews: [.sectionHeaders]) {
            Section(header: GridHeaderView(viewWidth: viewWidth, headerTitles: headerTitles)) {
                ForEach(data, id: \.self) { row in
                    ForEach(row, id: \.renderID) { item in
                        StonksGridItem(data: item, action: { onCellPress(item) })
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

private struct StonksGridItem<Content: StonkGridCellRenderable>: View {
    let data: Content
    let horizontalPadding: CGFloat
    let action: () -> Void

    init(data: Content, horizontalPadding: CGFloat = 16, action: @escaping () -> Void) {
        self.data = data
        self.horizontalPadding = horizontalPadding
        self.action = action
    }
    var body: some View {
        Button(action: action) {
            HStack {
                Text(data.content)
                    .foregroundColor(.accentColor)
                    .multilineTextAlignment(.leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.StonkBackground)
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal, horizontalPadding)
    }
}

#if DEBUG
private struct StonkGridRenderItem: StonkGridCellRenderable {
    let id: Int
    let content: String
    let transactionID: UUID
}

@available(macOS 11.0, iOS 14.0, *)
struct StonkGridView_Previews: PreviewProvider {
    static var previews: some View {
        StonkGridView(headerTitles: [], data: [] as [[StonkGridRenderItem]], viewWidth: 360, onCellPress: { _ in })
    }
}
#endif
