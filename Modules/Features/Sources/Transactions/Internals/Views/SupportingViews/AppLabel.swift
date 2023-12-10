//
//  AppLabel.swift
//
//
//  Created by Kamaal M Farah on 10/12/2023.
//

import SwiftUI

struct AppLabel: View {
    let title: String
    let value: String
    let valueColor: Color
    let textCase: Text.Case?

    init(title: String, value: String, valueColor: Color = .primary, textCase: Text.Case? = .lowercase) {
        self.title = title
        self.value = value
        self.valueColor = valueColor
        self.textCase = textCase
    }

    var body: some View {
        HStack {
            (Text(title) + Text(":"))
                .foregroundColor(.secondary)
            Text(value)
                .textCase(textCase)
                .foregroundColor(valueColor)
        }
        .ktakeWidthEagerly(alignment: .leading)
    }
}

#Preview {
    AppLabel(title: "Titler", value: "Values")
}
