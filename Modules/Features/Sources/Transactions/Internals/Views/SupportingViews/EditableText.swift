//
//  EditableText.swift
//
//
//  Created by Kamaal M Farah on 10/12/2023.
//

import SwiftUI
import KamaalUI

struct EditableText: View {
    @Binding var text: String

    let label: String
    let isEditing: Bool
    let textCase: Text.Case?

    init(text: Binding<String>, label: String, isEditing: Bool, textCase: Text.Case? = .lowercase) {
        self._text = text
        self.label = label
        self.isEditing = isEditing
        self.textCase = textCase
    }

    var body: some View {
        if isEditing {
            KFloatingTextField(text: $text, title: label)
        } else {
            AppLabel(title: label, value: text, textCase: textCase)
        }
    }
}

#Preview {
    EditableText(text: .constant("Hello"), label: "Greeting", isEditing: true)
}
