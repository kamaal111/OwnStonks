//
//  WideButton.swift
//  OwnStonks
//
//  Created by Kamaal M Farah on 05/01/2023.
//

import SwiftUI
import SalmonUI

struct WideButton<Content: View>: View {
    let action: () -> Void
    let content: () -> Content

    init(action: @escaping () -> Void, @ViewBuilder content: @escaping () -> Content) {
        self.action = action
        self.content = content
    }

    var body: some View {
        Button(action: action) {
            content()
                .ktakeWidthEagerly()
                .padding(.vertical, .extraSmall)
                .background(Color.accentColor)
                .cornerRadius(.extraSmall)
        }
        .buttonStyle(.plain)
    }
}

struct WideButton_Previews: PreviewProvider {
    static var previews: some View {
        WideButton(action: { }) {
            Text("Content")
        }
    }
}
