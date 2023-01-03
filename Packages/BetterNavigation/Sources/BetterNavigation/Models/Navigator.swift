//
//  Navigator.swift
//  
//
//  Created by Kamaal M Farah on 26/12/2022.
//

import SwiftUI
import SwiftStructures

public final class Navigator<StackValue: Codable & Hashable>: ObservableObject {
    @Published private var stacks: [StackValue: Stack<StackValue>]
    @Published public private(set) var currentStack: StackValue

    public init(stack: [StackValue], initialStack: StackValue) {
        let stack = Stack.fromArray(stack)
        self.stacks = [initialStack: stack]
        self.currentStack = initialStack
    }

    public var currentScreen: StackValue? {
        stacks[currentStack]?.peek()
    }

    @MainActor
    func changeStack(to stack: StackValue) {
        guard currentStack != stack else { return }

        if stacks[stack] == nil {
            stacks[stack] = Stack()
        }
        currentStack = stack
    }

    @MainActor
    func navigate(to destination: StackValue) {
        withAnimation { stacks[currentStack]?.push(destination) }
    }

    @MainActor
    func goBack() {
        withAnimation { _ = stacks[currentStack]?.pop() }
    }
}
