//
//  Navigator.swift
//  
//
//  Created by Kamaal M Farah on 26/12/2022.
//

import SwiftUI
import SwiftStructures

public final class Navigator<StackValue: Codable & Hashable>: ObservableObject {
    @Published private var stack: Stack<StackValue>

    init(stack: [StackValue]) {
        self.stack = .fromArray(stack)
    }

    public var currentScreen: StackValue? {
        stack.peek()
    }

    public var screens: [StackValue] {
        stack.array
    }

    @MainActor
    public func navigate(to destination: StackValue) {
        withAnimation(.easeOut(duration: 0.3)) {
            stack.push(destination)
        }
    }

    @MainActor
    public func goBack() {
        withAnimation(.easeOut(duration: 0.3)) {
            _ = stack.pop()
        }
    }
}
