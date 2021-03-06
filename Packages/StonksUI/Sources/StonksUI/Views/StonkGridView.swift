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
    public let isPressable: Bool
    public let onCellPress: (_ content: Content) -> Void

    public init(
        headerTitles: [String],
        data: [[Content]],
        viewWidth: CGFloat,
        isPressable: Bool,
        onCellPress: @escaping (_ content: Content) -> Void = { _ in }) {
        self.headerTitles = headerTitles
        self.data = data
        self.viewWidth = viewWidth
        self.isPressable = isPressable
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
                        StonksGridItem(data: item, isPressable: isPressable, action: { onCellPress(item) })
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
    let isPressable: Bool
    let action: () -> Void

    init(data: Content, horizontalPadding: CGFloat = 16, isPressable: Bool, action: @escaping () -> Void) {
        self.data = data
        self.horizontalPadding = horizontalPadding
        self.isPressable = isPressable
        self.action = action
    }
    var body: some View {
        ZStack {
            if isPressable {
                Button(action: action) {
                    Text(data.content)
                        .foregroundColor(.accentColor)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.StonkBackground)
                }
                .buttonStyle(PlainButtonStyle())
            } else {
                Text(data.content)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
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
        StonkGridView(
            headerTitles: [],
            data: [] as [[StonkGridRenderItem]],
            viewWidth: 360,
            isPressable: false,
            onCellPress: { _ in })
    }
}
#endif
