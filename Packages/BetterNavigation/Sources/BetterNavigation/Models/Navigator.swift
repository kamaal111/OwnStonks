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
        let stack = Stack.fromArray(stack)
        self.stack = stack
    }

    public var currentScreen: StackValue? {
        stack.peek()
    }

    @MainActor
    func navigate(to destination: StackValue) {
        stack.push(destination)
    }

    @MainActor
    func goBack() {
        _ = stack.pop()
    }
}
