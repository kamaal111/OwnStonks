//
//  EditableDecimalText.swift
//
//
//  Created by Kamaal M Farah on 10/12/2023.
//

import SwiftUI
import KamaalUI

public struct EditableDecimalText: View {
    @Binding var text: String

    let label: String
    let isEditing: Bool

    public init(text: Binding<String>, label: String, isEditing: Bool) {
        self._text = text
        self.label = label
        self.isEditing = isEditing
    }

    public var body: some View {
        if isEditing {
            KFloatingDecimalField(
                value: $text,
                title: label,
                fixButtonTitle: NSLocalizedString("Fix", bundle: .module, comment: ""),
                fixMessage: NSLocalizedString("Invalid value", bundle: .module, comment: "")
            )
        } else {
            AppLabel(title: label, value: text)
        }
    }
}

#Preview {
    EditableDecimalText(text: .constant("100.0"), label: "Yes", isEditing: false)
}
