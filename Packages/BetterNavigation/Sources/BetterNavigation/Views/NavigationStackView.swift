//
//  NavigationStackView.swift
//  
//
//  Created by Kamaal M Farah on 26/12/2022.
//

import SwiftUI
import SalmonUI
import SwiftStructures

public struct NavigationStackView<Root: View, SubView: View, StackValue: Codable & Equatable & Hashable>: View {
    @ObservedObject private var navigator: Navigator<StackValue>

    let root: () -> Root
    let subView: (StackValue) -> SubView

    public init(
        stack: [StackValue],
        @ViewBuilder root: @escaping () -> Root,
        @ViewBuilder subView: @escaping (StackValue) -> SubView) {
            self.root = root
            self.subView = subView
            self._navigator = ObservedObject(wrappedValue: Navigator<StackValue>(stack: stack))
        }

    public var body: some View {
        #if os(macOS)
        KJustStack {
            switch navigator.currentScreen {
            case .none:
                root()
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
        .environmentObject(navigator)
        #else
        root()
            .environmentObject(navigator)
        #endif
    }
}

struct NavigationStackView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStackView(stack: [] as [Int], root: { Text("Root") }, subView: { screen in Text("\(screen)") })
    }
}
