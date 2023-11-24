//
//  OSButton.swift
//  OwnStonks
//
//  Created by Kamaal M Farah on 29/12/2022.
//

import SwiftUI

struct OSButton<Content: View>: View {
    let action: () -> Void
    let content: () -> Content

    init(action: @escaping () -> Void, @ViewBuilder content: @escaping () -> Content) {
        self.action = action
        self.content = content
    }

    var body: some View {
        Button(action: action) {
            content()
                .invisibleFill()
        }
        .buttonStyle(.plain)
    }
}

struct OSButton_Previews: PreviewProvider {
    static var previews: some View {
        OSButton(action: { }) {
            Text("Content")
        }
    }
}
