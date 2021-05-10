//
//  NavigationButton.swift
//  
//
//  Created by Kamaal Farah on 10/05/2021.
//

import SwiftUI
import StonksLocale

public struct NavigationButton: View {
    public let title: String
    public let action: () -> Void

    public init(title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }

    public init(title: StonksLocale.Keys, action: @escaping () -> Void) {
        self.title = title.localized
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Text(title)
        }
    }
}

struct NavigationButton_Previews: PreviewProvider {
    static var previews: some View {
        NavigationButton(title: "Title", action: { })
    }
}
