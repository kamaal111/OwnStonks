//
//  EditableText.swift
//  OwnStonks
//
//  Created by Kamaal M Farah on 31/12/2022.
//

import SwiftUI
import SalmonUI
import OSLocales

struct EditableText: View {
    @Binding var text: String

    let title: String
    let isEditing: Bool

    init(text: Binding<String>, title: String, isEditing: Bool) {
        self._text = text
        self.title = title
        self.isEditing = isEditing
    }

    init(text: Binding<String>, localized: OSLocales.Keys, isEditing: Bool) {
        self.init(text: text, title: OSLocales.getText(localized), isEditing: isEditing)
    }

    var body: some View {
        if isEditing {
            KFloatingTextField(text: $text, title: title)
        } else {
            OSText("\(title): \(text)")
                .ktakeWidthEagerly(alignment: .leading)
        }
    }
}

struct EditableText_Previews: PreviewProvider {
    static var previews: some View {
        EditableText(text: .constant("Hallo"), title: "Title", isEditing: true)
    }
}
