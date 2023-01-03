//
//  NavigationStackView.swift
//  
//
//  Created by Kamaal M Farah on 26/12/2022.
//

import SwiftUI
import SalmonUI

public struct NavigationStackView<Root: View, SubView: View, Screen: Codable & Hashable>: View {
    @EnvironmentObject private var navigator: Navigator<Screen>

    let root: (Screen) -> Root
    let subView: (Screen) -> SubView

    public init(
        @ViewBuilder root: @escaping (Screen) -> Root,
        @ViewBuilder subView: @escaping (Screen) -> SubView) {
            self.root = root
            self.subView = subView
        }

    #warning("Make it support tab screen as well")
    public var body: some View {
        #if os(macOS)
        KJustStack {
            switch navigator.currentScreen {
            case .none:
                root(navigator.currentStack)
            case .some(let unwrapped):
                subView(unwrapped)
                    .id(unwrapped)
                    .transition(.move(edge: .trailing))
                    .toolbar {
                        ToolbarItem(placement: .navigation) {
                            Button(action: { navigator.goBack() }) {
                                Image(systemName: "chevron.left")
                                    .foregroundColor(.accentColor)
                            }
                        }
                    }
            }
        }
        #else
        root(navigator.currentStack)
        #endif
    }
}

struct NavigationStackView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStackView(root: { _ in Text("22") }, subView: { (screen: Int) in Text("\(screen)") })
    }
}
