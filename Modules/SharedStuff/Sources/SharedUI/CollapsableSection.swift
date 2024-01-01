//
//  CollapsableSection.swift
//
//
//  Created by Kamaal M Farah on 01/01/2024.
//

import SwiftUI
import KamaalUI

public struct CollapsableSection<Content: View>: View {
    @State private var isCollapsed = false

    public let title: String
    public let content: () -> Content

    public init(title: String, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.content = content
    }

    public var body: some View {
        VStack(alignment: .leading) {
            Section(header: header) {
                if !isCollapsed {
                    content()
                        .transition(.move(edge: .top))
                }
            }
        }
    }

    private var header: some View {
        Button(action: { withAnimation { isCollapsed.toggle() } }) {
            HStack {
                Text(title)
                    .foregroundStyle(.secondary)
                    .font(.callout)
                Spacer()
                Image(systemName: "chevron.down")
                    .foregroundStyle(.secondary)
                    .font(.callout)
                    .rotationEffect(.degrees(isCollapsed ? 90 : 0))
            }
            .kInvisibleFill()
            .background(content: {
                #if os(iOS)
                Color(uiColor: .systemBackground)
                #else
                Color(nsColor: .controlBackgroundColor)
                #endif
            })
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    CollapsableSection(title: "Collapsed or not") {
        Text("Content")
    }
}
