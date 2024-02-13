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
                        .transition(.asymmetric(insertion: .move(edge: .top), removal: .opacity))
                }
            }
        }
    }

    private var header: some View {
        Button(action: {
            if isCollapsed {
                withAnimation { isCollapsed = false }
            } else {
                withAnimation(.easeOut(duration: 0.2)) { isCollapsed = true }
            }
        }) {
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
